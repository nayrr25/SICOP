
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
