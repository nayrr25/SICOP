
CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_procedure_risk` AS
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
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_detalle_carteles`
  GROUP BY NRO_SICOP
),
institucion AS (
  SELECT
    NRO_SICOP,
    ARRAY_AGG(INSTITUCION IGNORE NULLS ORDER BY MES_DESCARGA DESC LIMIT 1)[SAFE_OFFSET(0)] AS nombre_institucion
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_invitacion_procedimiento`
  GROUP BY NRO_SICOP
),
cartel_lineas AS (
  SELECT
    NRO_SICOP,
    COUNT(*) AS lineas_cartel,
    SUM(SAFE_CAST(REPLACE(COALESCE(CANTIDAD_SOLICITADA, '0'), ',', '.') AS FLOAT64)) AS cantidad_solicitada_total,
    SUM(SAFE_CAST(REPLACE(COALESCE(MONTO_RESERVADO, '0'), ',', '.') AS FLOAT64)) AS monto_estimado_total,
    COUNT(DISTINCT CODIGO_IDENTIFICACION) AS productos_cartel
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_detalle_linea_cartel`
  GROUP BY NRO_SICOP
),
invitaciones AS (
  SELECT
    NRO_SICOP,
    COUNT(*) AS invitaciones,
    COUNT(DISTINCT CEDULA_PROVEEDOR) AS proveedores_invitados,
    MIN(FECHA_INVITACION) AS primera_invitacion,
    MAX(FECHA_INVITACION) AS ultima_invitacion
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_invitacion_procedimiento`
  GROUP BY NRO_SICOP
),
ofertas_agg AS (
  SELECT
    NRO_SICOP,
    COUNT(*) AS ofertas,
    COUNT(DISTINCT CEDULA_PROVEEDOR) AS proveedores_ofertantes,
    MIN(FECHA_PRESENTA_OFERTA) AS primera_oferta,
    MAX(FECHA_PRESENTA_OFERTA) AS ultima_oferta
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_ofertas`
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
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_ofertadas`
  GROUP BY NRO_SICOP
),
adjudicaciones AS (
  SELECT
    NRO_SICOP,
    COUNT(DISTINCT NRO_ACTO) AS actos_adjudicacion,
    MIN(FECHA_ADJ_FIRME) AS primera_adjudicacion,
    MAX(FECHA_ADJ_FIRME) AS ultima_adjudicacion
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_adjudicaciones_firme`
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
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_adjudicadas`
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
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_contratadas` lc
  LEFT JOIN `fifco-marketing-dev.ExploracionDataTeam.raw_contratos` c
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
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_recibidas`
  GROUP BY NRO_SICOP
),
recursos AS (
  SELECT NRO_SICOP, COUNT(DISTINCT NRO_RECURSO) AS recursos_objecion
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_recursos_objecion`
  GROUP BY NRO_SICOP
),
garantias_agg AS (
  SELECT
    NRO_SICOP,
    COUNT(DISTINCT nro_garantia) AS garantias,
    SUM(SAFE_CAST(REPLACE(COALESCE(MONTO, '0'), ',', '.') AS FLOAT64)) AS monto_garantias
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_garantias`
  GROUP BY NRO_SICOP
),
reajustes AS (
  SELECT
    NRO_SICOP,
    COUNT(*) AS reajustes_precio,
    SUM(SAFE_CAST(REPLACE(COALESCE(MONTO_REAJUSTE, '0'), ',', '.') AS FLOAT64)) AS monto_reajuste
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_reajuste_precios`
  GROUP BY NRO_SICOP
),
sanciones AS (
  SELECT
    la.NRO_SICOP,
    COUNT(DISTINCT sp.NO_RESOLUCION) AS sanciones_proveedor_adjudicado
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_adjudicadas` la
  JOIN `fifco-marketing-dev.ExploracionDataTeam.raw_sancion_proveedores` sp
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
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_detalle_linea_cartel` dc
  LEFT JOIN `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_ofertadas` lo
    ON lo.NRO_SICOP = dc.NRO_SICOP
   AND CAST(lo.NRO_LINEA AS STRING) = CAST(dc.NUMERO_LINEA AS STRING)
  LEFT JOIN `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_adjudicadas` la
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
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_detalle_linea_cartel` dc
  JOIN `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_ofertadas` lo
    ON lo.NRO_SICOP = dc.NRO_SICOP
   AND CAST(lo.NRO_LINEA AS STRING) = CAST(dc.NUMERO_LINEA AS STRING)
  GROUP BY dc.NRO_SICOP
),
provider_flags AS (
  SELECT
    la.NRO_SICOP,
    MAX(IF(o.CEDULA_PROVEEDOR IS NULL, 1, 0)) AS flag_proveedor_adjudicado_no_oferto
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_adjudicadas` la
  LEFT JOIN `fifco-marketing-dev.ExploracionDataTeam.raw_ofertas` o
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

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_procedure_risk_scored` AS
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
  FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_procedure_risk`
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

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_dashboard_summary` AS
SELECT
  COUNT(*) AS procedimientos,
  COUNTIF(score_riesgo >= 80) AS procedimientos_criticos,
  COUNTIF(score_riesgo >= 50) AS procedimientos_alto_o_critico,
  AVG(score_riesgo) AS score_promedio,
  SUM(monto_estimado_total) AS monto_estimado_total,
  SUM(monto_adjudicado_total) AS monto_adjudicado_total,
  SUM(monto_contratado_total) AS monto_contratado_total,
  SUM(flags_total) AS alertas_totales
FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_procedure_risk_scored`;

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_top_alertas` AS
SELECT *
FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_procedure_risk_scored`
WHERE score_riesgo > 0
ORDER BY score_riesgo DESC, monto_adjudicado_total DESC
LIMIT 1000;

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_linea_integrada` AS
WITH
cartel AS (
  SELECT
    dc.NRO_SICOP AS nro_sicop,
    dc.NRO_PROCEDIMIENTO AS nro_procedimiento,
    dc.CEDULA_INSTITUCION AS cedula_institucion,
    dc.TIPO_PROCEDIMIENTO AS tipo_procedimiento,
    dc.MODALIDAD_PROCEDIMIENTO AS modalidad_procedimiento,
    dc.FECHA_PUBLICACION AS fecha_publicacion,
    dc.FECHAH_APERTURA AS fecha_apertura,
    dl.NUMERO_LINEA AS nro_linea,
    dl.NUMERO_PARTIDA AS nro_partida,
    dl.CODIGO_IDENTIFICACION AS codigo_producto_cartel,
    SUBSTR(dl.CODIGO_IDENTIFICACION, 1, 4) AS cod_nivel1_cartel,
    dl.DESC_LINEA AS descripcion_linea_cartel,
    SAFE_CAST(REPLACE(COALESCE(dl.CANTIDAD_SOLICITADA, '0'), ',', '.') AS FLOAT64) AS cantidad_solicitada,
    SAFE_CAST(REPLACE(COALESCE(dl.PRECIO_UNITARIO_ESTIMADO, '0'), ',', '.') AS FLOAT64) AS precio_unitario_estimado,
    SAFE_CAST(REPLACE(COALESCE(dl.MONTO_RESERVADO, '0'), ',', '.') AS FLOAT64) AS monto_estimado_linea,
    dc.MES_DESCARGA AS mes_descarga
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_detalle_linea_cartel` dl
  LEFT JOIN `fifco-marketing-dev.ExploracionDataTeam.raw_detalle_carteles` dc
    ON dc.NRO_SICOP = dl.NRO_SICOP
),
oferta_linea AS (
  SELECT
    lo.NRO_SICOP AS nro_sicop,
    lo.NRO_OFERTA AS nro_oferta,
    lo.NRO_LINEA AS nro_linea,
    o.CEDULA_PROVEEDOR AS cedula_proveedor_oferta,
    o.FECHA_PRESENTA_OFERTA AS fecha_presenta_oferta,
    o.TIPO_OFERTA AS tipo_oferta,
    lo.CODIGO_PRODUCTO AS codigo_producto_oferta,
    SUBSTR(lo.CODIGO_PRODUCTO, 1, 4) AS cod_nivel1_oferta,
    SAFE_CAST(REPLACE(COALESCE(lo.CANTIDAD_OFERTADA, '0'), ',', '.') AS FLOAT64) AS cantidad_ofertada,
    SAFE_CAST(REPLACE(COALESCE(lo.PRECIO_UNITARIO_OFERTADO, '0'), ',', '.') AS FLOAT64) AS precio_unitario_ofertado,
    SAFE_CAST(REPLACE(COALESCE(lo.CANTIDAD_OFERTADA, '0'), ',', '.') AS FLOAT64)
      * SAFE_CAST(REPLACE(COALESCE(lo.PRECIO_UNITARIO_OFERTADO, '0'), ',', '.') AS FLOAT64) AS monto_ofertado_linea
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_ofertadas` lo
  LEFT JOIN `fifco-marketing-dev.ExploracionDataTeam.raw_ofertas` o
    ON o.NRO_SICOP = lo.NRO_SICOP
   AND o.NRO_OFERTA = lo.NRO_OFERTA
),
adjudicacion_linea AS (
  SELECT
    la.NRO_SICOP AS nro_sicop,
    la.NRO_OFERTA AS nro_oferta,
    la.NRO_LINEA AS nro_linea,
    la.NRO_ACTO AS nro_acto,
    la.CEDULA_PROVEEDOR AS cedula_proveedor_adjudicado,
    af.FECHA_ADJ_FIRME AS fecha_adj_firme,
    la.CODIGO_PRODUCTO AS codigo_producto_adjudicado,
    SUBSTR(la.CODIGO_PRODUCTO, 1, 4) AS cod_nivel1_adjudicado,
    SAFE_CAST(REPLACE(COALESCE(la.CANTIDAD_ADJUDICADA, '0'), ',', '.') AS FLOAT64) AS cantidad_adjudicada,
    SAFE_CAST(REPLACE(COALESCE(la.PRECIO_UNITARIO_ADJUDICADO, '0'), ',', '.') AS FLOAT64) AS precio_unitario_adjudicado,
    SAFE_CAST(REPLACE(COALESCE(la.CANTIDAD_ADJUDICADA, '0'), ',', '.') AS FLOAT64)
      * SAFE_CAST(REPLACE(COALESCE(la.PRECIO_UNITARIO_ADJUDICADO, '0'), ',', '.') AS FLOAT64) AS monto_adjudicado_linea
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_adjudicadas` la
  LEFT JOIN `fifco-marketing-dev.ExploracionDataTeam.raw_adjudicaciones_firme` af
    ON af.NRO_SICOP = la.NRO_SICOP
   AND af.NRO_ACTO = la.NRO_ACTO
),
invitacion AS (
  SELECT
    NRO_SICOP AS nro_sicop,
    CEDULA_PROVEEDOR AS cedula_proveedor,
    ARRAY_AGG(NOMBRE_PROVEEDOR IGNORE NULLS ORDER BY FECHA_INVITACION LIMIT 1)[SAFE_OFFSET(0)] AS nombre_proveedor,
    ARRAY_AGG(INSTITUCION IGNORE NULLS ORDER BY FECHA_INVITACION LIMIT 1)[SAFE_OFFSET(0)] AS nombre_institucion,
    ARRAY_AGG(CED_INSTITUCION IGNORE NULLS ORDER BY FECHA_INVITACION LIMIT 1)[SAFE_OFFSET(0)] AS cedula_institucion_invitacion,
    MIN(FECHA_INVITACION) AS fecha_invitacion
  FROM `fifco-marketing-dev.ExploracionDataTeam.raw_invitacion_procedimiento`
  GROUP BY nro_sicop, cedula_proveedor
),
integrada AS (
  SELECT
    c.*,
    ol.nro_oferta,
    ol.cedula_proveedor_oferta,
    inv.nombre_proveedor,
    inv.nombre_institucion,
    inv.cedula_institucion_invitacion,
    inv.fecha_invitacion,
    ol.fecha_presenta_oferta,
    ol.tipo_oferta,
    ol.codigo_producto_oferta,
    ol.cod_nivel1_oferta,
    ol.cantidad_ofertada,
    ol.precio_unitario_ofertado,
    ol.monto_ofertado_linea,
    al.nro_acto,
    al.cedula_proveedor_adjudicado,
    al.fecha_adj_firme,
    al.codigo_producto_adjudicado,
    al.cod_nivel1_adjudicado,
    al.cantidad_adjudicada,
    al.precio_unitario_adjudicado,
    al.monto_adjudicado_linea
  FROM cartel c
  LEFT JOIN oferta_linea ol
    ON ol.nro_sicop = c.nro_sicop
   AND CAST(ol.nro_linea AS STRING) = CAST(c.nro_linea AS STRING)
  LEFT JOIN adjudicacion_linea al
    ON al.nro_sicop = c.nro_sicop
   AND CAST(al.nro_linea AS STRING) = CAST(c.nro_linea AS STRING)
   AND COALESCE(al.nro_oferta, '') = COALESCE(ol.nro_oferta, '')
  LEFT JOIN invitacion inv
    ON inv.nro_sicop = c.nro_sicop
   AND inv.cedula_proveedor = ol.cedula_proveedor_oferta
),
percentiles AS (
  SELECT
    APPROX_QUANTILES(monto_estimado_linea, 100)[OFFSET(95)] AS p95_monto_estimado_linea,
    APPROX_QUANTILES(monto_ofertado_linea, 100)[OFFSET(95)] AS p95_monto_ofertado_linea,
    APPROX_QUANTILES(monto_adjudicado_linea, 100)[OFFSET(95)] AS p95_monto_adjudicado_linea,
    APPROX_QUANTILES(cantidad_solicitada, 100)[OFFSET(95)] AS p95_cantidad_solicitada,
    APPROX_QUANTILES(cantidad_ofertada, 100)[OFFSET(95)] AS p95_cantidad_ofertada,
    APPROX_QUANTILES(cantidad_adjudicada, 100)[OFFSET(95)] AS p95_cantidad_adjudicada
  FROM integrada
)
SELECT
  i.*,
  IF(i.fecha_publicacion IS NOT NULL AND i.fecha_invitacion IS NOT NULL AND i.fecha_publicacion > i.fecha_invitacion, 1, 0) AS flag_publicacion_posterior_invitacion,
  IF(i.fecha_invitacion IS NOT NULL AND i.fecha_presenta_oferta IS NOT NULL AND i.fecha_invitacion > i.fecha_presenta_oferta, 1, 0) AS flag_invitacion_posterior_oferta_linea,
  IF(i.fecha_presenta_oferta IS NOT NULL AND i.fecha_adj_firme IS NOT NULL AND i.fecha_presenta_oferta > i.fecha_adj_firme, 1, 0) AS flag_oferta_posterior_adjudicacion,
  IF(i.monto_estimado_linea > 0 AND i.monto_ofertado_linea IS NOT NULL AND ABS(i.monto_estimado_linea - i.monto_ofertado_linea) / i.monto_estimado_linea > 0.05, 1, 0) AS flag_monto_ofertado_difiere_5pct_linea,
  IF(i.monto_estimado_linea > 0 AND i.monto_adjudicado_linea IS NOT NULL AND ABS(i.monto_estimado_linea - i.monto_adjudicado_linea) / i.monto_estimado_linea > 0.05, 1, 0) AS flag_monto_adjudicado_difiere_5pct_linea,
  IF(i.cantidad_solicitada IS NOT NULL AND i.cantidad_ofertada IS NOT NULL AND i.cantidad_solicitada < i.cantidad_ofertada, 1, 0) AS flag_cantidad_solicitada_menor_ofertada,
  IF(i.cantidad_solicitada IS NOT NULL AND i.cantidad_adjudicada IS NOT NULL AND i.cantidad_solicitada < i.cantidad_adjudicada, 1, 0) AS flag_cantidad_solicitada_menor_adjudicada,
  IF(i.cod_nivel1_cartel IS NOT NULL AND i.cod_nivel1_oferta IS NOT NULL AND i.cod_nivel1_cartel <> i.cod_nivel1_oferta, 1, 0) AS flag_codigo_nivel1_cartel_oferta_distinto,
  IF(i.cedula_institucion IS NOT NULL AND i.cedula_institucion_invitacion IS NOT NULL AND i.cedula_institucion <> i.cedula_institucion_invitacion, 1, 0) AS flag_institucion_distinta,
  IF(i.cedula_proveedor_oferta IS NOT NULL AND i.cedula_proveedor_adjudicado IS NOT NULL AND i.cedula_proveedor_oferta <> i.cedula_proveedor_adjudicado, 1, 0) AS flag_proveedor_oferta_adjudicacion_distinto,
  (
    IF(i.monto_estimado_linea > p.p95_monto_estimado_linea AND p.p95_monto_estimado_linea > 0, 1, 0)
    + IF(i.monto_ofertado_linea > p.p95_monto_ofertado_linea AND p.p95_monto_ofertado_linea > 0, 1, 0)
    + IF(i.monto_adjudicado_linea > p.p95_monto_adjudicado_linea AND p.p95_monto_adjudicado_linea > 0, 1, 0)
    + IF(i.cantidad_solicitada > p.p95_cantidad_solicitada AND p.p95_cantidad_solicitada > 0, 1, 0)
    + IF(i.cantidad_ofertada > p.p95_cantidad_ofertada AND p.p95_cantidad_ofertada > 0, 1, 0)
    + IF(i.cantidad_adjudicada > p.p95_cantidad_adjudicada AND p.p95_cantidad_adjudicada > 0, 1, 0)
  ) AS flags_anomalia_estadistica_linea
FROM integrada i
CROSS JOIN percentiles p;

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_inconsistencias_linea` AS
SELECT * FROM (
  SELECT nro_sicop, nro_procedimiento, nro_linea, nro_oferta, cedula_institucion, nombre_institucion, cedula_proveedor_oferta, nombre_proveedor, 'Publicacion posterior a invitacion' AS tipo_inconsistencia, 'fecha_publicacion' AS columna_1, 'fecha_invitacion' AS columna_2, CAST(fecha_publicacion AS STRING) AS valor_1, CAST(fecha_invitacion AS STRING) AS valor_2, mes_descarga FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_linea_integrada` WHERE flag_publicacion_posterior_invitacion = 1
  UNION ALL
  SELECT nro_sicop, nro_procedimiento, nro_linea, nro_oferta, cedula_institucion, nombre_institucion, cedula_proveedor_oferta, nombre_proveedor, 'Invitacion posterior a oferta', 'fecha_invitacion', 'fecha_presenta_oferta', CAST(fecha_invitacion AS STRING), CAST(fecha_presenta_oferta AS STRING), mes_descarga FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_linea_integrada` WHERE flag_invitacion_posterior_oferta_linea = 1
  UNION ALL
  SELECT nro_sicop, nro_procedimiento, nro_linea, nro_oferta, cedula_institucion, nombre_institucion, cedula_proveedor_oferta, nombre_proveedor, 'Oferta posterior a adjudicacion firme', 'fecha_presenta_oferta', 'fecha_adj_firme', CAST(fecha_presenta_oferta AS STRING), CAST(fecha_adj_firme AS STRING), mes_descarga FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_linea_integrada` WHERE flag_oferta_posterior_adjudicacion = 1
  UNION ALL
  SELECT nro_sicop, nro_procedimiento, nro_linea, nro_oferta, cedula_institucion, nombre_institucion, cedula_proveedor_oferta, nombre_proveedor, 'Diferencia significativa en monto ofertado', 'monto_estimado_linea', 'monto_ofertado_linea', CAST(monto_estimado_linea AS STRING), CAST(monto_ofertado_linea AS STRING), mes_descarga FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_linea_integrada` WHERE flag_monto_ofertado_difiere_5pct_linea = 1
  UNION ALL
  SELECT nro_sicop, nro_procedimiento, nro_linea, nro_oferta, cedula_institucion, nombre_institucion, cedula_proveedor_oferta, nombre_proveedor, 'Diferencia significativa en monto adjudicado', 'monto_estimado_linea', 'monto_adjudicado_linea', CAST(monto_estimado_linea AS STRING), CAST(monto_adjudicado_linea AS STRING), mes_descarga FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_linea_integrada` WHERE flag_monto_adjudicado_difiere_5pct_linea = 1
  UNION ALL
  SELECT nro_sicop, nro_procedimiento, nro_linea, nro_oferta, cedula_institucion, nombre_institucion, cedula_proveedor_oferta, nombre_proveedor, 'Cantidad solicitada menor que ofertada', 'cantidad_solicitada', 'cantidad_ofertada', CAST(cantidad_solicitada AS STRING), CAST(cantidad_ofertada AS STRING), mes_descarga FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_linea_integrada` WHERE flag_cantidad_solicitada_menor_ofertada = 1
  UNION ALL
  SELECT nro_sicop, nro_procedimiento, nro_linea, nro_oferta, cedula_institucion, nombre_institucion, cedula_proveedor_oferta, nombre_proveedor, 'Cantidad solicitada menor que adjudicada', 'cantidad_solicitada', 'cantidad_adjudicada', CAST(cantidad_solicitada AS STRING), CAST(cantidad_adjudicada AS STRING), mes_descarga FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_linea_integrada` WHERE flag_cantidad_solicitada_menor_adjudicada = 1
  UNION ALL
  SELECT nro_sicop, nro_procedimiento, nro_linea, nro_oferta, cedula_institucion, nombre_institucion, cedula_proveedor_oferta, nombre_proveedor, 'Inconsistencia en codigo de producto', 'cod_nivel1_cartel', 'cod_nivel1_oferta', CAST(cod_nivel1_cartel AS STRING), CAST(cod_nivel1_oferta AS STRING), mes_descarga FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_linea_integrada` WHERE flag_codigo_nivel1_cartel_oferta_distinto = 1
  UNION ALL
  SELECT nro_sicop, nro_procedimiento, nro_linea, nro_oferta, cedula_institucion, nombre_institucion, cedula_proveedor_oferta, nombre_proveedor, 'Inconsistencia en informacion de institucion', 'cedula_institucion', 'cedula_institucion_invitacion', CAST(cedula_institucion AS STRING), CAST(cedula_institucion_invitacion AS STRING), mes_descarga FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_linea_integrada` WHERE flag_institucion_distinta = 1
  UNION ALL
  SELECT nro_sicop, nro_procedimiento, nro_linea, nro_oferta, cedula_institucion, nombre_institucion, cedula_proveedor_oferta, nombre_proveedor, 'Inconsistencia en informacion de proveedor', 'cedula_proveedor_oferta', 'cedula_proveedor_adjudicado', CAST(cedula_proveedor_oferta AS STRING), CAST(cedula_proveedor_adjudicado AS STRING), mes_descarga FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_linea_integrada` WHERE flag_proveedor_oferta_adjudicacion_distinto = 1
  UNION ALL
  SELECT nro_sicop, nro_procedimiento, nro_linea, nro_oferta, cedula_institucion, nombre_institucion, cedula_proveedor_oferta, nombre_proveedor, 'Anomalia estadistica de linea', 'metricas_linea', 'percentil_95', CAST(flags_anomalia_estadistica_linea AS STRING), 'supera umbral', mes_descarga FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_linea_integrada` WHERE flags_anomalia_estadistica_linea > 0
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_inconsistencias_resumen` AS
SELECT
  tipo_inconsistencia,
  COUNT(*) AS total_registros,
  COUNT(DISTINCT nro_sicop) AS procedimientos_afectados,
  COUNT(DISTINCT cedula_proveedor_oferta) AS proveedores_afectados
FROM `fifco-marketing-dev.ExploracionDataTeam.nai_sicop_inconsistencias_linea`
GROUP BY tipo_inconsistencia
ORDER BY total_registros DESC;
