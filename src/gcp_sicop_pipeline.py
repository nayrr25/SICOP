#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import http.client
import json
import os
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path


PROJECT_ID = "fifco-marketing-dev"
DATASET = "ExploracionDataTeam"
LOCATION = "US"
ADC_PATH = Path.home() / ".config/gcloud/application_default_credentials.json"
TOKEN_URL = "https://oauth2.googleapis.com/token"

TABLES = {
    "AdjudicacionesFirme.csv": "adjudicaciones_firme",
    "Contratos.csv": "contratos",
    "DetalleCarteles.csv": "detalle_carteles",
    "DetalleLineaCartel.csv": "detalle_linea_cartel",
    "FechaPorEtapas.csv": "fecha_por_etapas",
    "FuncionariosInhibicion.csv": "funcionarios_inhibicion",
    "Garantias.csv": "garantias",
    "InstitucionesRegistradas.csv": "instituciones_registradas",
    "InvitacionProcedimiento.csv": "invitacion_procedimiento",
    "LineasAdjudicadas.csv": "lineas_adjudicadas",
    "LineasContratadas.csv": "lineas_contratadas",
    "LineasOfertadas.csv": "lineas_ofertadas",
    "LineasRecibidas.csv": "lineas_recibidas",
    "Ofertas.csv": "ofertas",
    "OrdenPedido.csv": "orden_pedido",
    "ProcedimientoADM.csv": "procedimiento_adm",
    "ProcedimientoAdjudicacion.csv": "procedimiento_adjudicacion",
    "Proveedores.csv": "proveedores",
    "ReajustePrecios.csv": "reajuste_precios",
    "Recepciones.csv": "recepciones",
    "RecursosObjecion.csv": "recursos_objecion",
    "Remates.csv": "remates",
    "SancionProveedores.csv": "sancion_proveedores",
    "SistemaEvaluacionOfertas.csv": "sistema_evaluacion_ofertas",
    "Sistemas.csv": "sistemas",
}


def default_schema_profile() -> Path:
    return Path(__file__).resolve().parents[1] / "docs" / "sicop_schema_profile.json"


def log(message: str) -> None:
    print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {message}", flush=True)


def request_json(url: str, token: str | None = None, data: dict | None = None, method: str | None = None) -> dict:
    body = json.dumps(data).encode("utf-8") if data is not None else None
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=120) as response:
        raw = response.read().decode("utf-8")
    return json.loads(raw) if raw else {}


def refresh_access_token(credentials_path: Path) -> str:
    credentials = json.loads(credentials_path.read_text(encoding="utf-8"))
    payload = urllib.parse.urlencode(
        {
            "client_id": credentials["client_id"],
            "client_secret": credentials["client_secret"],
            "refresh_token": credentials["refresh_token"],
            "grant_type": "refresh_token",
        }
    ).encode("utf-8")
    req = urllib.request.Request(TOKEN_URL, data=payload)
    with urllib.request.urlopen(req, timeout=60) as response:
        return json.loads(response.read().decode("utf-8"))["access_token"]


def clean_prefix(prefix: str) -> str:
    return prefix.strip("/")


def object_name(path: Path, raw_base: Path, prefix: str) -> str:
    base_prefix = clean_prefix(prefix)
    month = ""
    for part in path.parts:
        if re.fullmatch(r"20\d{4}", part):
            month = part
            break
    if not month:
        rel = path.relative_to(raw_base)
        return f"{base_prefix}/{rel.as_posix()}" if base_prefix else rel.as_posix()
    name = f"{month}/{path.name}"
    return f"{base_prefix}/{name}" if base_prefix else name


def iter_csvs(raw_base: Path) -> list[Path]:
    return sorted(p for p in raw_base.rglob("*.csv") if p.name in TABLES)


def ensure_bucket(token: str, bucket: str, project: str, create: bool, location: str) -> None:
    url = f"https://storage.googleapis.com/storage/v1/b/{bucket}"
    try:
        request_json(url, token=token)
        log(f"Bucket OK: gs://{bucket}")
        return
    except urllib.error.HTTPError as exc:
        if exc.code != 404 or not create:
            raise
    create_url = f"https://storage.googleapis.com/storage/v1/b?project={project}"
    request_json(
        create_url,
        token=token,
        data={"name": bucket, "location": location, "storageClass": "STANDARD"},
        method="POST",
    )
    log(f"Bucket creado: gs://{bucket}")


def remote_size(token: str, bucket: str, name: str) -> int | None:
    encoded = urllib.parse.quote(name, safe="")
    url = f"https://storage.googleapis.com/storage/v1/b/{bucket}/o/{encoded}?fields=size"
    try:
        meta = request_json(url, token=token)
        return int(meta.get("size", 0))
    except urllib.error.HTTPError as exc:
        if exc.code == 404:
            return None
        raise


def upload_file(token: str, bucket: str, source: Path, name: str, force: bool = False) -> None:
    size = source.stat().st_size
    if not force and remote_size(token, bucket, name) == size:
        log(f"Skip existe: gs://{bucket}/{name}")
        return

    start_url = (
        f"https://storage.googleapis.com/upload/storage/v1/b/{bucket}/o"
        f"?uploadType=resumable&name={urllib.parse.quote(name, safe='')}"
    )
    req = urllib.request.Request(
        start_url,
        data=json.dumps({"name": name}).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "X-Upload-Content-Type": "text/csv",
            "X-Upload-Content-Length": str(size),
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=120) as response:
        session_url = response.headers["Location"]

    parsed = urllib.parse.urlparse(session_url)
    conn = http.client.HTTPSConnection(parsed.netloc, timeout=600)
    path = parsed.path + (f"?{parsed.query}" if parsed.query else "")
    conn.putrequest("PUT", path)
    conn.putheader("Authorization", f"Bearer {token}")
    conn.putheader("Content-Type", "text/csv")
    conn.putheader("Content-Length", str(size))
    conn.endheaders()
    with source.open("rb") as fh:
        while True:
            chunk = fh.read(8 * 1024 * 1024)
            if not chunk:
                break
            conn.send(chunk)
    response = conn.getresponse()
    body = response.read().decode("utf-8", errors="replace")
    conn.close()
    if response.status not in (200, 201):
        raise RuntimeError(f"Upload fallo {source}: HTTP {response.status} {body[:500]}")
    log(f"Subido: gs://{bucket}/{name}")


def run_query(token: str, project: str, location: str, sql: str, label: str) -> dict:
    log(f"BigQuery inicia: {label}")
    url = f"https://bigquery.googleapis.com/bigquery/v2/projects/{project}/jobs"
    job = request_json(
        url,
        token=token,
        data={
            "configuration": {
                "query": {
                    "query": sql,
                    "useLegacySql": False,
                    "createSession": False,
                }
            },
            "jobReference": {"projectId": project, "location": location},
        },
        method="POST",
    )
    job_id = job["jobReference"]["jobId"]
    poll_url = f"https://bigquery.googleapis.com/bigquery/v2/projects/{project}/jobs/{job_id}?location={location}"
    while True:
        status = request_json(poll_url, token=token)
        state = status["status"]["state"]
        if state == "DONE":
            if "errorResult" in status["status"]:
                raise RuntimeError(json.dumps(status["status"], indent=2, ensure_ascii=False))
            log(f"BigQuery listo: {label}")
            return status
        time.sleep(5)


def fq(table: str, project: str = PROJECT_ID, dataset: str = DATASET) -> str:
    return f"`{project}.{dataset}.{table}`"


def bq_col(name: str) -> str:
    return "`" + name.replace("`", "") + "`"


def normalize_col(name: str) -> str:
    text = unicodedata.normalize("NFKD", name or "")
    text = "".join(ch for ch in text if not unicodedata.combining(ch))
    text = text.strip().replace("\ufeff", "")
    text = re.sub(r"[^0-9A-Za-z_]+", "_", text)
    text = re.sub(r"_+", "_", text).strip("_")
    if not text:
        text = "COL"
    if text[0].isdigit():
        text = "_" + text
    return text.upper()


def schema_columns(schema_profile: Path, csv_name: str) -> list[str]:
    profile = json.loads(schema_profile.read_text(encoding="utf-8"))
    columns: list[str] = []
    seen: dict[str, int] = {}
    for raw in profile["files"][csv_name]["columns"]:
        col = normalize_col(raw)
        if col in seen:
            seen[col] += 1
            col = f"{col}_{seen[col]}"
        else:
            seen[col] = 1
        columns.append(col)
    return columns


def schema_delimiter(schema_profile: Path, csv_name: str) -> str:
    profile = json.loads(schema_profile.read_text(encoding="utf-8"))
    delimiters = profile["files"][csv_name].get("delimiters", {})
    if not delimiters:
        return ";"
    return max(delimiters.items(), key=lambda item: int(item[1]))[0]


def build_external_sql(bucket: str, prefix: str, project: str, dataset: str, schema_profile: Path) -> str:
    statements = []
    base_prefix = clean_prefix(prefix)
    for csv_name, table in TABLES.items():
        ext = f"ext_{table}"
        raw = f"raw_{table}"
        uri = f"gs://{bucket}/{base_prefix}/*/{csv_name}" if base_prefix else f"gs://{bucket}/*/{csv_name}"
        columns = schema_columns(schema_profile, csv_name)
        schema = ",\n  ".join(f"{bq_col(col)} STRING" for col in columns)
        raw_schema = schema + ",\n  `MES_DESCARGA` STRING,\n  `SOURCE_FILE` STRING"
        delimiter = schema_delimiter(schema_profile, csv_name)
        if csv_name == "Sistemas.csv":
            statements.append(
                f"""
CREATE OR REPLACE TABLE {fq(raw, project, dataset)} (
  {raw_schema}
);
"""
            )
            continue
        statements.append(
            f"""
CREATE OR REPLACE EXTERNAL TABLE {fq(ext, project, dataset)} (
  {schema}
)
OPTIONS (
  format = 'CSV',
  uris = ['{uri}'],
  field_delimiter = '{delimiter}',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE {fq(raw, project, dataset)} AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{{6}})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM {fq(ext, project, dataset)};
"""
        )
    return "\n".join(statements)


def risk_sql(project: str, dataset: str) -> str:
    # All source columns are treated defensively because SICOP monthly extracts
    # have schema drift. The output table is the product-ready audit layer.
    return f"""
CREATE OR REPLACE TABLE {fq('nai_sicop_procedure_risk', project, dataset)} AS
WITH
proc AS (
  SELECT
    NRO_SICOP,
    MIN(NRO_PROCEDIMIENTO) AS nro_procedimiento,
    MIN(CEDULA_INSTITUCION) AS cedula_institucion,
    MIN(TIPO_PROCEDIMIENTO) AS tipo_procedimiento,
    MIN(MODALIDAD_PROCEDIMIENTO) AS modalidad_procedimiento,
    MIN(DES_EXCEPCION) AS des_excepcion,
    MIN(COD_EXCEPCION) AS cod_excepcion,
    MIN(CLAS_OBJ) AS clas_obj,
    MIN(FECHA_PUBLICACION) AS fecha_publicacion,
    MIN(FECHAH_APERTURA) AS fecha_apertura,
    MAX(MES_DESCARGA) AS mes_descarga
  FROM {fq('raw_detalle_carteles', project, dataset)}
  GROUP BY NRO_SICOP
),
institucion AS (
  SELECT
    NRO_SICOP,
    ARRAY_AGG(INSTITUCION IGNORE NULLS ORDER BY MES_DESCARGA DESC LIMIT 1)[SAFE_OFFSET(0)] AS nombre_institucion
  FROM {fq('raw_invitacion_procedimiento', project, dataset)}
  GROUP BY NRO_SICOP
),
cartel_lineas AS (
  SELECT
    NRO_SICOP,
    COUNT(*) AS lineas_cartel,
    SUM(SAFE_CAST(REPLACE(COALESCE(CANTIDAD_SOLICITADA, '0'), ',', '.') AS FLOAT64)) AS cantidad_solicitada_total,
    SUM(SAFE_CAST(REPLACE(COALESCE(MONTO_RESERVADO, '0'), ',', '.') AS FLOAT64)) AS monto_estimado_total,
    COUNT(DISTINCT CODIGO_IDENTIFICACION) AS productos_cartel
  FROM {fq('raw_detalle_linea_cartel', project, dataset)}
  GROUP BY NRO_SICOP
),
invitaciones AS (
  SELECT
    NRO_SICOP,
    COUNT(*) AS invitaciones,
    COUNT(DISTINCT CEDULA_PROVEEDOR) AS proveedores_invitados,
    MIN(FECHA_INVITACION) AS primera_invitacion,
    MAX(FECHA_INVITACION) AS ultima_invitacion
  FROM {fq('raw_invitacion_procedimiento', project, dataset)}
  GROUP BY NRO_SICOP
),
ofertas_agg AS (
  SELECT
    NRO_SICOP,
    COUNT(*) AS ofertas,
    COUNT(DISTINCT CEDULA_PROVEEDOR) AS proveedores_ofertantes,
    MIN(FECHA_PRESENTA_OFERTA) AS primera_oferta,
    MAX(FECHA_PRESENTA_OFERTA) AS ultima_oferta
  FROM {fq('raw_ofertas', project, dataset)}
  GROUP BY NRO_SICOP
),
ofertas_lineas AS (
  SELECT
    NRO_SICOP,
    COUNT(*) AS lineas_ofertadas,
    SUM(SAFE_CAST(REPLACE(COALESCE(CANTIDAD_OFERTADA, '0'), ',', '.') AS FLOAT64)) AS cantidad_ofertada_total,
    SUM(
      SAFE_CAST(REPLACE(COALESCE(CANTIDAD_OFERTADA, '0'), ',', '.') AS FLOAT64)
      * SAFE_CAST(REPLACE(COALESCE(PRECIO_UNITARIO_OFERTADO, '0'), ',', '.') AS FLOAT64)
    ) AS monto_ofertado_total,
    COUNT(DISTINCT CODIGO_PRODUCTO) AS productos_ofertados
  FROM {fq('raw_lineas_ofertadas', project, dataset)}
  GROUP BY NRO_SICOP
),
adjudicaciones AS (
  SELECT
    NRO_SICOP,
    COUNT(DISTINCT NRO_ACTO) AS actos_adjudicacion,
    MIN(FECHA_ADJ_FIRME) AS primera_adjudicacion,
    MAX(FECHA_ADJ_FIRME) AS ultima_adjudicacion
  FROM {fq('raw_adjudicaciones_firme', project, dataset)}
  GROUP BY NRO_SICOP
),
adjudicaciones_lineas AS (
  SELECT
    NRO_SICOP,
    COUNT(*) AS lineas_adjudicadas,
    COUNT(DISTINCT CEDULA_PROVEEDOR) AS proveedores_adjudicados,
    SUM(SAFE_CAST(REPLACE(COALESCE(CANTIDAD_ADJUDICADA, '0'), ',', '.') AS FLOAT64)) AS cantidad_adjudicada_total,
    SUM(
      SAFE_CAST(REPLACE(COALESCE(CANTIDAD_ADJUDICADA, '0'), ',', '.') AS FLOAT64)
      * SAFE_CAST(REPLACE(COALESCE(PRECIO_UNITARIO_ADJUDICADO, '0'), ',', '.') AS FLOAT64)
    ) AS monto_adjudicado_total,
    COUNT(DISTINCT CODIGO_PRODUCTO) AS productos_adjudicados
  FROM {fq('raw_lineas_adjudicadas', project, dataset)}
  GROUP BY NRO_SICOP
),
contratos_agg AS (
  SELECT
    lc.NRO_SICOP,
    COUNT(DISTINCT lc.NRO_CONTRATO) AS contratos,
    COUNT(*) AS lineas_contratadas,
    SUM(SAFE_CAST(REPLACE(COALESCE(lc.CANTIDAD_CONTRATADA, '0'), ',', '.') AS FLOAT64)) AS cantidad_contratada_total,
    SUM(
      SAFE_CAST(REPLACE(COALESCE(lc.CANTIDAD_CONTRATADA, '0'), ',', '.') AS FLOAT64)
      * SAFE_CAST(REPLACE(COALESCE(lc.PRECIO_UNITARIO, '0'), ',', '.') AS FLOAT64)
    ) AS monto_contratado_total,
    MIN(c.FECHA_ELABORACION) AS primera_elaboracion_contrato,
    MIN(c.FECHA_NOTIFICACION) AS primera_notificacion_contrato
  FROM {fq('raw_lineas_contratadas', project, dataset)} lc
  LEFT JOIN {fq('raw_contratos', project, dataset)} c
    ON c.NRO_CONTRATO = lc.NRO_CONTRATO
   AND COALESCE(c.SECUENCIA, '') = COALESCE(lc.SECUENCIA, '')
  GROUP BY lc.NRO_SICOP
),
recepciones_agg AS (
  SELECT
    NRO_SICOP,
    COUNT(DISTINCT NRO_RECEP_DEFINITIVA) AS recepciones_definitivas,
    COUNT(*) AS lineas_recibidas,
    SUM(SAFE_CAST(REPLACE(COALESCE(CANTIDAD_REAL_RECIBIDA, '0'), ',', '.') AS FLOAT64)) AS cantidad_recibida_total,
    MIN(fecha_recepcion_Definitiva) AS primera_recepcion_definitiva
  FROM {fq('raw_lineas_recibidas', project, dataset)}
  GROUP BY NRO_SICOP
),
recursos AS (
  SELECT NRO_SICOP, COUNT(DISTINCT NRO_RECURSO) AS recursos_objecion
  FROM {fq('raw_recursos_objecion', project, dataset)}
  GROUP BY NRO_SICOP
),
garantias_agg AS (
  SELECT
    NRO_SICOP,
    COUNT(DISTINCT nro_garantia) AS garantias,
    SUM(SAFE_CAST(REPLACE(COALESCE(MONTO, '0'), ',', '.') AS FLOAT64)) AS monto_garantias
  FROM {fq('raw_garantias', project, dataset)}
  GROUP BY NRO_SICOP
),
reajustes AS (
  SELECT
    NRO_SICOP,
    COUNT(*) AS reajustes_precio,
    SUM(SAFE_CAST(REPLACE(COALESCE(MONTO_REAJUSTE, '0'), ',', '.') AS FLOAT64)) AS monto_reajuste
  FROM {fq('raw_reajuste_precios', project, dataset)}
  GROUP BY NRO_SICOP
),
sanciones AS (
  SELECT
    la.NRO_SICOP,
    COUNT(DISTINCT sp.NO_RESOLUCION) AS sanciones_proveedor_adjudicado
  FROM {fq('raw_lineas_adjudicadas', project, dataset)} la
  JOIN {fq('raw_sancion_proveedores', project, dataset)} sp
    ON sp.CEDULA_PROVEEDOR = la.CEDULA_PROVEEDOR
  GROUP BY la.NRO_SICOP
),
line_quantity_flags AS (
  SELECT
    dc.NRO_SICOP,
    MAX(IF(
      SAFE_CAST(REPLACE(COALESCE(lo.CANTIDAD_OFERTADA, '0'), ',', '.') AS FLOAT64)
      > SAFE_CAST(REPLACE(COALESCE(dc.CANTIDAD_SOLICITADA, '0'), ',', '.') AS FLOAT64), 1, 0
    )) AS flag_cantidad_ofertada_mayor_solicitada,
    MAX(IF(
      SAFE_CAST(REPLACE(COALESCE(la.CANTIDAD_ADJUDICADA, '0'), ',', '.') AS FLOAT64)
      > SAFE_CAST(REPLACE(COALESCE(dc.CANTIDAD_SOLICITADA, '0'), ',', '.') AS FLOAT64), 1, 0
    )) AS flag_cantidad_adjudicada_mayor_solicitada
  FROM {fq('raw_detalle_linea_cartel', project, dataset)} dc
  LEFT JOIN {fq('raw_lineas_ofertadas', project, dataset)} lo
    ON lo.NRO_SICOP = dc.NRO_SICOP
   AND CAST(lo.NRO_LINEA AS STRING) = CAST(dc.NUMERO_LINEA AS STRING)
  LEFT JOIN {fq('raw_lineas_adjudicadas', project, dataset)} la
    ON la.NRO_SICOP = dc.NRO_SICOP
   AND CAST(la.NRO_LINEA AS STRING) = CAST(dc.NUMERO_LINEA AS STRING)
  GROUP BY dc.NRO_SICOP
),
product_flags AS (
  SELECT
    dc.NRO_SICOP,
    MAX(IF(
      dc.CODIGO_IDENTIFICACION IS NOT NULL
      AND lo.CODIGO_PRODUCTO IS NOT NULL
      AND SUBSTR(dc.CODIGO_IDENTIFICACION, 1, 4) <> SUBSTR(lo.CODIGO_PRODUCTO, 1, 4), 1, 0
    )) AS flag_codigo_producto_distinto
  FROM {fq('raw_detalle_linea_cartel', project, dataset)} dc
  JOIN {fq('raw_lineas_ofertadas', project, dataset)} lo
    ON lo.NRO_SICOP = dc.NRO_SICOP
   AND CAST(lo.NRO_LINEA AS STRING) = CAST(dc.NUMERO_LINEA AS STRING)
  GROUP BY dc.NRO_SICOP
),
provider_flags AS (
  SELECT
    la.NRO_SICOP,
    MAX(IF(o.CEDULA_PROVEEDOR IS NULL, 1, 0)) AS flag_proveedor_adjudicado_no_oferto
  FROM {fq('raw_lineas_adjudicadas', project, dataset)} la
  LEFT JOIN {fq('raw_ofertas', project, dataset)} o
    ON o.NRO_SICOP = la.NRO_SICOP
   AND o.NRO_OFERTA = la.NRO_OFERTA
   AND o.CEDULA_PROVEEDOR = la.CEDULA_PROVEEDOR
  GROUP BY la.NRO_SICOP
)
SELECT
  p.NRO_SICOP AS nro_sicop,
  p.nro_procedimiento,
  p.cedula_institucion,
  i.nombre_institucion,
  p.tipo_procedimiento,
  p.modalidad_procedimiento,
  p.des_excepcion,
  p.cod_excepcion,
  p.clas_obj,
  p.fecha_publicacion,
  p.fecha_apertura,
  p.mes_descarga,
  COALESCE(cl.lineas_cartel, 0) AS lineas_cartel,
  COALESCE(cl.cantidad_solicitada_total, 0) AS cantidad_solicitada_total,
  COALESCE(cl.monto_estimado_total, 0) AS monto_estimado_total,
  COALESCE(inv.invitaciones, 0) AS invitaciones,
  COALESCE(inv.proveedores_invitados, 0) AS proveedores_invitados,
  inv.primera_invitacion,
  inv.ultima_invitacion,
  COALESCE(oa.ofertas, 0) AS ofertas,
  COALESCE(oa.proveedores_ofertantes, 0) AS proveedores_ofertantes,
  oa.primera_oferta,
  oa.ultima_oferta,
  COALESCE(ol.lineas_ofertadas, 0) AS lineas_ofertadas,
  COALESCE(ol.cantidad_ofertada_total, 0) AS cantidad_ofertada_total,
  COALESCE(ol.monto_ofertado_total, 0) AS monto_ofertado_total,
  COALESCE(adj.actos_adjudicacion, 0) AS actos_adjudicacion,
  adj.primera_adjudicacion,
  adj.ultima_adjudicacion,
  COALESCE(al.lineas_adjudicadas, 0) AS lineas_adjudicadas,
  COALESCE(al.proveedores_adjudicados, 0) AS proveedores_adjudicados,
  COALESCE(al.cantidad_adjudicada_total, 0) AS cantidad_adjudicada_total,
  COALESCE(al.monto_adjudicado_total, 0) AS monto_adjudicado_total,
  COALESCE(c.contratos, 0) AS contratos,
  COALESCE(c.lineas_contratadas, 0) AS lineas_contratadas,
  COALESCE(c.cantidad_contratada_total, 0) AS cantidad_contratada_total,
  COALESCE(c.monto_contratado_total, 0) AS monto_contratado_total,
  c.primera_elaboracion_contrato,
  c.primera_notificacion_contrato,
  COALESCE(rec.recepciones_definitivas, 0) AS recepciones_definitivas,
  COALESCE(rec.lineas_recibidas, 0) AS lineas_recibidas,
  COALESCE(rec.cantidad_recibida_total, 0) AS cantidad_recibida_total,
  rec.primera_recepcion_definitiva,
  COALESCE(res.recursos_objecion, 0) AS recursos_objecion,
  COALESCE(g.garantias, 0) AS garantias,
  COALESCE(g.monto_garantias, 0) AS monto_garantias,
  COALESCE(rj.reajustes_precio, 0) AS reajustes_precio,
  COALESCE(rj.monto_reajuste, 0) AS monto_reajuste,
  COALESCE(s.sanciones_proveedor_adjudicado, 0) AS sanciones_proveedor_adjudicado,
  IF(oa.primera_oferta IS NOT NULL AND p.fecha_publicacion IS NOT NULL AND oa.primera_oferta < p.fecha_publicacion, 1, 0) AS flag_oferta_antes_publicacion,
  IF(inv.primera_invitacion IS NOT NULL AND oa.primera_oferta IS NOT NULL AND inv.primera_invitacion > oa.primera_oferta, 1, 0) AS flag_invitacion_posterior_oferta,
  IF(adj.primera_adjudicacion IS NOT NULL AND oa.primera_oferta IS NOT NULL AND adj.primera_adjudicacion < oa.primera_oferta, 1, 0) AS flag_adjudicacion_antes_oferta,
  IF(c.primera_elaboracion_contrato IS NOT NULL AND adj.primera_adjudicacion IS NOT NULL AND c.primera_elaboracion_contrato < adj.primera_adjudicacion, 1, 0) AS flag_contrato_antes_adjudicacion,
  IF(COALESCE(cl.monto_estimado_total, 0) > 0 AND COALESCE(ol.monto_ofertado_total, 0) > 0 AND ABS(ol.monto_ofertado_total - cl.monto_estimado_total) / cl.monto_estimado_total > 0.05, 1, 0) AS flag_monto_ofertado_difiere_5pct,
  IF(COALESCE(cl.monto_estimado_total, 0) > 0 AND COALESCE(al.monto_adjudicado_total, 0) > 0 AND ABS(al.monto_adjudicado_total - cl.monto_estimado_total) / cl.monto_estimado_total > 0.05, 1, 0) AS flag_monto_adjudicado_difiere_5pct,
  IF(COALESCE(cl.monto_estimado_total, 0) > 0 AND COALESCE(c.monto_contratado_total, 0) > 0 AND ABS(c.monto_contratado_total - cl.monto_estimado_total) / cl.monto_estimado_total > 0.05, 1, 0) AS flag_monto_contratado_difiere_5pct,
  COALESCE(q.flag_cantidad_ofertada_mayor_solicitada, 0) AS flag_cantidad_ofertada_mayor_solicitada,
  COALESCE(q.flag_cantidad_adjudicada_mayor_solicitada, 0) AS flag_cantidad_adjudicada_mayor_solicitada,
  COALESCE(pf.flag_codigo_producto_distinto, 0) AS flag_codigo_producto_distinto,
  COALESCE(vf.flag_proveedor_adjudicado_no_oferto, 0) AS flag_proveedor_adjudicado_no_oferto,
  IF(COALESCE(al.lineas_adjudicadas, 0) > 0 AND COALESCE(c.contratos, 0) = 0, 1, 0) AS flag_adjudicado_sin_contrato,
  IF(COALESCE(c.contratos, 0) > 0 AND COALESCE(rec.recepciones_definitivas, 0) = 0, 1, 0) AS flag_contrato_sin_recepcion,
  IF(COALESCE(s.sanciones_proveedor_adjudicado, 0) > 0, 1, 0) AS flag_proveedor_sancionado
FROM proc p
LEFT JOIN institucion i ON i.NRO_SICOP = p.NRO_SICOP
LEFT JOIN cartel_lineas cl ON cl.NRO_SICOP = p.NRO_SICOP
LEFT JOIN invitaciones inv ON inv.NRO_SICOP = p.NRO_SICOP
LEFT JOIN ofertas_agg oa ON oa.NRO_SICOP = p.NRO_SICOP
LEFT JOIN ofertas_lineas ol ON ol.NRO_SICOP = p.NRO_SICOP
LEFT JOIN adjudicaciones adj ON adj.NRO_SICOP = p.NRO_SICOP
LEFT JOIN adjudicaciones_lineas al ON al.NRO_SICOP = p.NRO_SICOP
LEFT JOIN contratos_agg c ON c.NRO_SICOP = p.NRO_SICOP
LEFT JOIN recepciones_agg rec ON rec.NRO_SICOP = p.NRO_SICOP
LEFT JOIN recursos res ON res.NRO_SICOP = p.NRO_SICOP
LEFT JOIN garantias_agg g ON g.NRO_SICOP = p.NRO_SICOP
LEFT JOIN reajustes rj ON rj.NRO_SICOP = p.NRO_SICOP
LEFT JOIN sanciones s ON s.NRO_SICOP = p.NRO_SICOP
LEFT JOIN line_quantity_flags q ON q.NRO_SICOP = p.NRO_SICOP
LEFT JOIN product_flags pf ON pf.NRO_SICOP = p.NRO_SICOP
LEFT JOIN provider_flags vf ON vf.NRO_SICOP = p.NRO_SICOP;

CREATE OR REPLACE TABLE {fq('nai_sicop_procedure_risk_scored', project, dataset)} AS
WITH base AS (
  SELECT
    *,
    (
      flag_oferta_antes_publicacion * 25
      + flag_invitacion_posterior_oferta * 35
      + flag_adjudicacion_antes_oferta * 40
      + flag_contrato_antes_adjudicacion * 35
      + flag_monto_ofertado_difiere_5pct * 20
      + flag_monto_adjudicado_difiere_5pct * 30
      + flag_monto_contratado_difiere_5pct * 25
      + flag_cantidad_ofertada_mayor_solicitada * 20
      + flag_cantidad_adjudicada_mayor_solicitada * 30
      + flag_codigo_producto_distinto * 20
      + flag_proveedor_adjudicado_no_oferto * 35
      + flag_adjudicado_sin_contrato * 30
      + flag_contrato_sin_recepcion * 15
      + flag_proveedor_sancionado * 40
    ) AS score_reglas,
    (
      flag_oferta_antes_publicacion
      + flag_invitacion_posterior_oferta
      + flag_adjudicacion_antes_oferta
      + flag_contrato_antes_adjudicacion
      + flag_monto_ofertado_difiere_5pct
      + flag_monto_adjudicado_difiere_5pct
      + flag_monto_contratado_difiere_5pct
      + flag_cantidad_ofertada_mayor_solicitada
      + flag_cantidad_adjudicada_mayor_solicitada
      + flag_codigo_producto_distinto
      + flag_proveedor_adjudicado_no_oferto
      + flag_adjudicado_sin_contrato
      + flag_contrato_sin_recepcion
      + flag_proveedor_sancionado
    ) AS flags_total
  FROM {fq('nai_sicop_procedure_risk', project, dataset)}
),
percentiles AS (
  SELECT
    APPROX_QUANTILES(monto_estimado_total, 100)[OFFSET(95)] AS p95_monto_estimado,
    APPROX_QUANTILES(monto_adjudicado_total, 100)[OFFSET(95)] AS p95_monto_adjudicado,
    APPROX_QUANTILES(monto_contratado_total, 100)[OFFSET(95)] AS p95_monto_contratado,
    APPROX_QUANTILES(ofertas, 100)[OFFSET(95)] AS p95_ofertas,
    APPROX_QUANTILES(lineas_cartel, 100)[OFFSET(95)] AS p95_lineas,
    APPROX_QUANTILES(recursos_objecion, 100)[OFFSET(95)] AS p95_recursos
  FROM base
)
SELECT
  b.*,
  (
    IF(b.monto_estimado_total > p.p95_monto_estimado AND p.p95_monto_estimado > 0, 1, 0)
    + IF(b.monto_adjudicado_total > p.p95_monto_adjudicado AND p.p95_monto_adjudicado > 0, 1, 0)
    + IF(b.monto_contratado_total > p.p95_monto_contratado AND p.p95_monto_contratado > 0, 1, 0)
    + IF(b.ofertas > p.p95_ofertas AND p.p95_ofertas > 0, 1, 0)
    + IF(b.lineas_cartel > p.p95_lineas AND p.p95_lineas > 0, 1, 0)
    + IF(b.recursos_objecion > p.p95_recursos AND p.p95_recursos > 0, 1, 0)
  ) AS flags_estadisticos,
  LEAST(100, b.score_reglas + (
    IF(b.monto_estimado_total > p.p95_monto_estimado AND p.p95_monto_estimado > 0, 5, 0)
    + IF(b.monto_adjudicado_total > p.p95_monto_adjudicado AND p.p95_monto_adjudicado > 0, 5, 0)
    + IF(b.monto_contratado_total > p.p95_monto_contratado AND p.p95_monto_contratado > 0, 5, 0)
    + IF(b.ofertas > p.p95_ofertas AND p.p95_ofertas > 0, 5, 0)
    + IF(b.lineas_cartel > p.p95_lineas AND p.p95_lineas > 0, 5, 0)
    + IF(b.recursos_objecion > p.p95_recursos AND p.p95_recursos > 0, 5, 0)
  )) AS score_riesgo,
  CASE
    WHEN LEAST(100, b.score_reglas) >= 80 THEN 'Critico'
    WHEN LEAST(100, b.score_reglas) >= 50 THEN 'Alto'
    WHEN LEAST(100, b.score_reglas) >= 25 THEN 'Medio'
    ELSE 'Bajo'
  END AS nivel_riesgo
FROM base b
CROSS JOIN percentiles p;

CREATE OR REPLACE TABLE {fq('nai_sicop_dashboard_summary', project, dataset)} AS
SELECT
  COUNT(*) AS procedimientos,
  COUNTIF(score_riesgo >= 80) AS procedimientos_criticos,
  COUNTIF(score_riesgo >= 50) AS procedimientos_alto_o_critico,
  AVG(score_riesgo) AS score_promedio,
  SUM(monto_estimado_total) AS monto_estimado_total,
  SUM(monto_adjudicado_total) AS monto_adjudicado_total,
  SUM(monto_contratado_total) AS monto_contratado_total,
  SUM(flags_total) AS alertas_totales
FROM {fq('nai_sicop_procedure_risk_scored', project, dataset)};

CREATE OR REPLACE TABLE {fq('nai_sicop_top_alertas', project, dataset)} AS
SELECT *
FROM {fq('nai_sicop_procedure_risk_scored', project, dataset)}
WHERE score_riesgo > 0
ORDER BY score_riesgo DESC, monto_adjudicado_total DESC
LIMIT 1000;
"""


def write_sql_files(out_dir: Path, bucket: str, prefix: str, project: str, dataset: str, schema_profile: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "01_external_and_raw_tables.sql").write_text(
        build_external_sql(bucket, prefix, project, dataset, schema_profile), encoding="utf-8"
    )
    (out_dir / "02_risk_model.sql").write_text(risk_sql(project, dataset), encoding="utf-8")
    log(f"SQL generado en {out_dir}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Carga SICOP a GCP y construye tablas NAI Analytics.")
    parser.add_argument("--project", default=PROJECT_ID)
    parser.add_argument("--dataset", default=DATASET)
    parser.add_argument("--location", default=LOCATION)
    parser.add_argument("--bucket", required=True)
    parser.add_argument("--gcs-prefix", default="sicop/raw")
    parser.add_argument("--raw-base", default="/Users/nancyrodriguez/Documents/Contraloria/bases")
    parser.add_argument("--credentials", default=str(ADC_PATH))
    parser.add_argument("--sql-out", default="gcp_sicop/generated_sql")
    parser.add_argument("--schema-profile", default="")
    parser.add_argument("--create-bucket", action="store_true")
    parser.add_argument("--upload", action="store_true")
    parser.add_argument("--force-upload", action="store_true")
    parser.add_argument("--upload-workers", type=int, default=8)
    parser.add_argument("--create-bigquery", action="store_true")
    parser.add_argument("--build-risk", action="store_true")
    args = parser.parse_args()

    raw_base = Path(args.raw_base)
    if not raw_base.exists():
        raise SystemExit(f"No existe raw-base: {raw_base}")
    credentials = Path(args.credentials)
    if not credentials.exists():
        raise SystemExit(f"No existen credenciales ADC: {credentials}")
    schema_profile = Path(args.schema_profile) if args.schema_profile else default_schema_profile()
    if not schema_profile.exists():
        raise SystemExit(f"No existe perfil de esquema: {schema_profile}")

    write_sql_files(Path(args.sql_out), args.bucket, args.gcs_prefix, args.project, args.dataset, schema_profile)

    needs_google_api = args.upload or args.create_bigquery or args.build_risk
    token = refresh_access_token(credentials) if needs_google_api else ""

    if args.upload:
        ensure_bucket(token, args.bucket, args.project, args.create_bucket, args.location)
        files = iter_csvs(raw_base)
        log(f"CSV a subir: {len(files)}")
        workers = max(1, args.upload_workers)
        if workers == 1:
            for idx, path in enumerate(files, 1):
                upload_file(token, args.bucket, path, object_name(path, raw_base, args.gcs_prefix), force=args.force_upload)
                if idx % 25 == 0:
                    log(f"Avance upload: {idx}/{len(files)}")
        else:
            completed = 0
            with ThreadPoolExecutor(max_workers=workers) as executor:
                futures = {
                    executor.submit(
                        upload_file,
                        token,
                        args.bucket,
                        path,
                        object_name(path, raw_base, args.gcs_prefix),
                        args.force_upload,
                    ): path
                    for path in files
                }
                for future in as_completed(futures):
                    future.result()
                    completed += 1
                    if completed % 25 == 0:
                        log(f"Avance upload: {completed}/{len(files)}")

    if args.create_bigquery:
        run_query(
            token,
            args.project,
            args.location,
            build_external_sql(args.bucket, args.gcs_prefix, args.project, args.dataset, schema_profile),
            "external y raw tables",
        )

    if args.build_risk:
        run_query(token, args.project, args.location, risk_sql(args.project, args.dataset), "risk model")

    log("Proceso terminado.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
