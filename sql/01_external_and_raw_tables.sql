
CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_adjudicaciones_firme` (
  `NRO_SICOP` STRING,
  `NRO_ACTO` STRING,
  `FECHA_ADJ_FIRME` STRING,
  `PERMITE_RECURSOS` STRING,
  `DESIERTO` STRING,
  `FECHA_REV` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/AdjudicacionesFirme.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_adjudicaciones_firme` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_adjudicaciones_firme`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_contratos` (
  `NRO_CONTRATO` STRING,
  `NRO_CONTRATO_WEB` STRING,
  `SECUENCIA` STRING,
  `NUMERO_PROCEDIMIENTO` STRING,
  `CEDULA_PROVEEDOR` STRING,
  `NRO_SICOP` STRING,
  `CEDULA_INSTITUCION` STRING,
  `FECHA_INI_PRORR` STRING,
  `FECHA_FIN_PRORR` STRING,
  `VIGENCIA` STRING,
  `MONEDA` STRING,
  `FECHA_INI_SUSP` STRING,
  `PLAZO_SUSP` STRING,
  `FECHA_REINI_CONT` STRING,
  `FECHA_MODIFICACION` STRING,
  `TIPO_CONTRATO` STRING,
  `TIPO_MODIFICACION` STRING,
  `FECHA_NOTIFICACION` STRING,
  `FECHA_ELABORACION` STRING,
  `TIPO_AUTORIZACION` STRING,
  `TIPO_DISMINUCION` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/Contratos.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_contratos` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_contratos`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_detalle_carteles` (
  `NRO_SICOP` STRING,
  `CEDULA_INSTITUCION` STRING,
  `FECHA_PUBLICACION` STRING,
  `NRO_PROCEDIMIENTO` STRING,
  `TIPO_PROCEDIMIENTO` STRING,
  `MODALIDAD_PROCEDIMIENTO` STRING,
  `DES_EXCEPCION` STRING,
  `MONTO_EST` STRING,
  `FECHA_MOD` STRING,
  `CARTEL_STAT` STRING,
  `CARTEL_NM` STRING,
  `FECHAH_APERTURA` STRING,
  `CODIGO_BPIP` STRING,
  `CLAS_OBJ` STRING,
  `COD_EXCEPCION` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/DetalleCarteles.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_detalle_carteles` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_detalle_carteles`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_detalle_linea_cartel` (
  `NRO_SICOP` STRING,
  `NUMERO_LINEA` STRING,
  `NUMERO_PARTIDA` STRING,
  `CANTIDAD_SOLICITADA` STRING,
  `PRECIO_UNITARIO_ESTIMADO` STRING,
  `TIPO_MONEDA` STRING,
  `TIPO_CAMBIO_CRC` STRING,
  `TIPO_CAMBIO_DOLAR` STRING,
  `CODIGO_IDENTIFICACION` STRING,
  `MONTO_RESERVADO` STRING,
  `DESC_LINEA` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/DetalleLineaCartel.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_detalle_linea_cartel` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_detalle_linea_cartel`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_fecha_por_etapas` (
  `NRO_SICOP` STRING,
  `NUMERO_PROCEDIMIENTO` STRING,
  `CARTEL_SEQ` STRING,
  `PARTIDA` STRING,
  `LINEA` STRING,
  `PUBLICACION` STRING,
  `FECHA_1RA_SOL_PAGO` STRING,
  `FECHA_ULT_SOL_PAGO` STRING,
  `FECHA_RESUL_PAGO` STRING,
  `SOLICITUD_APROBACION_CONTRATO` STRING,
  `RESPUESTA_APROBACION_CONTRATO` STRING,
  `FECHA_NOTIFICACION` STRING,
  `FECHA_1RA_SOL_RECEPCION` STRING,
  `FECHA_1RA_SOL_RECEP_PROVI` STRING,
  `FECHA_ULT_SOL_RECEP_DEFI` STRING,
  `RESPUESTA_RECOM_ADJUD` STRING,
  `SOLICITUD_ADJUD` STRING,
  `RESPUESTA_ADJUD` STRING,
  `ADJUDICACION_FIRME` STRING,
  `FECHA_RESUL_PAGO_ESP_FISCALES` STRING,
  `FECHA_ELABORACION_CONTRATO` STRING,
  `FECHA_APERTURA` STRING,
  `SOLICITUD_ESTUDIOS_TECNICOS` STRING,
  `COMUNICACION` STRING,
  `SOLICITUD_PAGO_ESP_FISCALES` STRING,
  `RESPUESTA_ESTUDIOS_TECNICOS` STRING,
  `SOLICITUD_RECOM_ADJUD` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/FechaPorEtapas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_fecha_por_etapas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_fecha_por_etapas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_funcionarios_inhibicion` (
  `CED_INSTITUCION` STRING,
  `CED_FUNCIONARIO` STRING,
  `NOM_FUNCIONARIO` STRING,
  `FECHA_INICIO` STRING,
  `FECHA_FIN` STRING,
  `ESTADO` STRING,
  `FECHA_REGISTRO` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/FuncionariosInhibicion.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_funcionarios_inhibicion` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_funcionarios_inhibicion`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_garantias` (
  `NRO_SICOP` STRING,
  `NUMERO_PROCEDIMIENTO` STRING,
  `DESCRIPCION_PROCEDIMIENTO` STRING,
  `TIPO_PROCEDIMIENTO` STRING,
  `NOMBRE_INSTITUCION` STRING,
  `CEDULA_INSTITUCION` STRING,
  `FECHA_REGISTRO` STRING,
  `NRO_GARANTIA` STRING,
  `CED_GARANTE` STRING,
  `GARA_SEQ` STRING,
  `NOMBRE_PROVEEDOR` STRING,
  `CEDULA_PROVEEDOR` STRING,
  `TIPO_GARANTIA` STRING,
  `MONTO` STRING,
  `ESTADO` STRING,
  `GARANTIA_NM` STRING,
  `VIGENCIA` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/Garantias.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_garantias` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_garantias`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_instituciones_registradas` (
  `CEDULA` STRING,
  `NOMBRE_INSTITUCION` STRING,
  `ZONA_GEO_INST` STRING,
  `FECHA_INGRESO` STRING,
  `FECHA_MOD` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/InstitucionesRegistradas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_instituciones_registradas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_instituciones_registradas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_invitacion_procedimiento` (
  `SECUENCIA` STRING,
  `CED_INSTITUCION` STRING,
  `INSTITUCION` STRING,
  `NRO_SICOP` STRING,
  `CEDULA_PROVEEDOR` STRING,
  `NOMBRE_PROVEEDOR` STRING,
  `NUMERO_PROCEDIMIENTO` STRING,
  `FECHA_INVITACION` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/InvitacionProcedimiento.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_invitacion_procedimiento` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_invitacion_procedimiento`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_adjudicadas` (
  `NRO_SICOP` STRING,
  `NRO_OFERTA` STRING,
  `CODIGO_PRODUCTO` STRING,
  `NRO_LINEA` STRING,
  `NRO_ACTO` STRING,
  `CEDULA_PROVEEDOR` STRING,
  `ACARREOS` STRING,
  `TIPO_CAMBIO_CRC` STRING,
  `TIPO_CAMBIO_DOLAR` STRING,
  `CANTIDAD_ADJUDICADA` STRING,
  `PRECIO_UNITARIO_ADJUDICADO` STRING,
  `TIPO_MONEDA` STRING,
  `DESCUENTO` STRING,
  `IVA` STRING,
  `OTROS_IMPUESTOS` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/LineasAdjudicadas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_adjudicadas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_adjudicadas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_contratadas` (
  `NRO_SICOP` STRING,
  `NRO_LINEA_CONTRATO` STRING,
  `NRO_LINEA_CARTEL` STRING,
  `NRO_CONTRATO` STRING,
  `SECUENCIA` STRING,
  `CEDULA_PROVEEDOR` STRING,
  `CANTIDAD_AUMENTADA` STRING,
  `CANTIDAD_DISMINUIDA` STRING,
  `MONTO_AUMENTADO` STRING,
  `MONTO_DISMINUIDO` STRING,
  `OTROS_IMPUESTOS` STRING,
  `ACARREOS` STRING,
  `TIPO_CAMBIO_CRC` STRING,
  `TIPO_CAMBIO_DOLAR` STRING,
  `NRO_ACTO` STRING,
  `DESC_PRODUCTO` STRING,
  `CODIGO_PRODUCTO` STRING,
  `CANTIDAD_CONTRATADA` STRING,
  `PRECIO_UNITARIO` STRING,
  `TIPO_MONEDA` STRING,
  `DESCUENTO` STRING,
  `IVA` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/LineasContratadas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_contratadas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_contratadas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_ofertadas` (
  `NRO_SICOP` STRING,
  `NRO_OFERTA` STRING,
  `NRO_LINEA` STRING,
  `CODIGO_PRODUCTO` STRING,
  `CANTIDAD_OFERTADA` STRING,
  `PRECIO_UNITARIO_OFERTADO` STRING,
  `TIPO_CAMBIO_DOLAR` STRING,
  `TIPO_MONEDA` STRING,
  `DESCUENTO` STRING,
  `IVA` STRING,
  `OTROS_IMPUESTOS` STRING,
  `ACARREOS` STRING,
  `TIPO_CAMBIO_CRC` STRING,
  `CODIGO_PRODUCTO_CL` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/LineasOfertadas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_ofertadas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_ofertadas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_recibidas` (
  `NRO_SICOP` STRING,
  `NRO_CONTRATO` STRING,
  `SECUENCIA` STRING,
  `NRO_RECEP_PROVISIONAL` STRING,
  `ESTADO_RECEP_PROVISIONAL` STRING,
  `NRO_RECEP_DEFINITIVA` STRING,
  `PRECIO` STRING,
  `DIAS_ADELANTO_ATRASO` STRING,
  `FECHA_RECEPCION_DEFINITIVA` STRING,
  `ESTADO_RECEP_DEFINITIVA` STRING,
  `NRO_LINEA` STRING,
  `ENTREGA` STRING,
  `CODIGO_PRODUCTO` STRING,
  `CANTIDAD_REAL_RECIBIDA` STRING,
  `DESC_PRODUCTO` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/LineasRecibidas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_recibidas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_recibidas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_ofertas` (
  `NRO_SICOP` STRING,
  `NRO_OFERTA` STRING,
  `CEDULA_PROVEEDOR` STRING,
  `FECHA_PRESENTA_OFERTA` STRING,
  `TIPO_OFERTA` STRING,
  `ID_CONSORCIO` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/Ofertas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_ofertas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_ofertas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_orden_pedido` (
  `NRO_SICOP` STRING,
  `NUMERO_PROCEDIMIENTO` STRING,
  `NRO_CONTRATO` STRING,
  `CONTRACT_NO` STRING,
  `SECUENCIA_CONTRATO` STRING,
  `TOTAL_ORDEN` STRING,
  `FECHA_PROVEEDOR_RECIBE_ORDEN` STRING,
  `LINEA_ORD_PEDIDO` STRING,
  `FECHA_REC_PEDIDO` STRING,
  `SECUENCIA` STRING,
  `FECHA_PROV_RECIBE_ORDEN` STRING,
  `USD_MONT` STRING,
  `NRO_ORDEN` STRING,
  `MONEDA_ORDEN` STRING,
  `FECHA_NOTIFICACION_ORDEN` STRING,
  `FECHA_ELABORACION_ORDEN` STRING,
  `TOTALESTIMADO` STRING,
  `ESTADO_ORDEN` STRING,
  `DESC_PROCEDIMIENTO` STRING,
  `CEDULAPROVEEDOR` STRING,
  `NOMBRE_PROVEEDOR` STRING,
  `FECHAREGISTRO` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/OrdenPedido.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_orden_pedido` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_orden_pedido`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_procedimiento_adm` (
  `NRO_SICOP` STRING,
  `NUMERO_PROCEDIMIENTO` STRING,
  `NOMBRE_PROVEEDOR` STRING,
  `NUMERO_PA` STRING,
  `NOMBRE_INSTITUCION` STRING,
  `CEDULA_INSTITUCION` STRING,
  `CEDULA_PROVEEDOR` STRING,
  `FECHA_NOTIFICACION` STRING,
  `INHAB_APERC` STRING,
  `MULTA_CAUSULA` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/ProcedimientoADM.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_procedimiento_adm` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_procedimiento_adm`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_procedimiento_adjudicacion` (
  `CEDULA` STRING,
  `INSTITUCION` STRING,
  `ANO` STRING,
  `NUMERO_PROCEDIMIENTO` STRING,
  `DESCR_PROCEDIMIENTO` STRING,
  `LINEA` STRING,
  `NRO_SICOP` STRING,
  `TIPO_PROCEDIMIENTO` STRING,
  `MODALIDAD_PROCEDIMIENTO` STRING,
  `FECHA_REV` STRING,
  `CEDULA_PROVEEDOR` STRING,
  `NOMBRE_PROVEEDOR` STRING,
  `PERFIL_PROV` STRING,
  `CEDULA_REPRESENTANTE` STRING,
  `REPRESENTANTE` STRING,
  `OBJETO_GASTO` STRING,
  `MONEDA_ADJUDICADA` STRING,
  `MONTO_ADJU_LINEA` STRING,
  `MONTO_ADJU_LINEA_CRC` STRING,
  `MONTO_ADJU_LINEA_USD` STRING,
  `FECHA_ADJUD_FIRME` STRING,
  `FECHA_SOL_CONTRA` STRING,
  `PROD_ID` STRING,
  `DESCR_BIEN_SERVICIO` STRING,
  `CANTIDAD` STRING,
  `UNIDAD_MEDIDA` STRING,
  `MONTO_UNITARIO` STRING,
  `MONEDA_PRECIO_EST` STRING,
  `FECHA_SOL_CONTRA_CL` STRING,
  `PROD_ID_CL` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/ProcedimientoAdjudicacion.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_procedimiento_adjudicacion` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_procedimiento_adjudicacion`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_proveedores` (
  `CEDULA_PROVEEDOR` STRING,
  `NOMBRE_PROVEEDOR` STRING,
  `TIPO_PROVEEDOR` STRING,
  `TAMANO_PROVEEDOR` STRING,
  `FECHA_CONSTITUCION` STRING,
  `FECHA_EXPIRACION` STRING,
  `ZONA_GEO_PROV` STRING,
  `FECHA_REGISTRO` STRING,
  `FECHA_MOD` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/Proveedores.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_proveedores` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_proveedores`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_reajuste_precios` (
  `NRO_SICOP` STRING,
  `NUMERO_PROCEDIMIENTO` STRING,
  `NOMBRE_INSTITUCION` STRING,
  `CEDULA_INSTITUCION` STRING,
  `CEDULA_PROVEEDOR` STRING,
  `NOMBRE_PROVEEDOR` STRING,
  `FECHA_INICIO` STRING,
  `FECHA_FIN` STRING,
  `MESES_APP` STRING,
  `DIAS_APP` STRING,
  `TIPO_MONEDA` STRING,
  `MONTO_TOTAL` STRING,
  `PRECIO_UNITARIO` STRING,
  `NUMERO_REAJUSTE` STRING,
  `PRECIO_ANT_ULT_RJ` STRING,
  `MONTO_REAJUSTE` STRING,
  `NUEVO_PRECIO` STRING,
  `PORC_INCR_ULT_RJ` STRING,
  `FECHA_ELABORACION` STRING,
  `CODIGO_PRODUCTO` STRING,
  `DES_PRODUCTO` STRING,
  `NRO_CONTRATO` STRING,
  `NRO_LINEA_CONTRATO` STRING,
  `CANTIDAD_CONTRATADA` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/ReajustePrecios.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_reajuste_precios` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_reajuste_precios`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_recepciones` (
  `NRO_SICOP` STRING,
  `NRO_CONTRATO` STRING,
  `NRO_RECEP_DEFINITIVA` STRING,
  `FECHA_RECEP_DEFINITIVA` STRING,
  `NRO_PROCEDIMIENTO` STRING,
  `CEDULA_PROVEEDOR` STRING,
  `CEDULA_INSTITUCION` STRING,
  `MONEDA` STRING,
  `NOMBRE_PROVEEDOR` STRING,
  `FECHA_ENT_INI` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/Recepciones.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_recepciones` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_recepciones`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_recursos_objecion` (
  `NRO_RECURSO` STRING,
  `CEDULA_PROVEEDOR` STRING,
  `NRO_SICOP` STRING,
  `NRO_ACTO` STRING,
  `LINEA_OBJETADA` STRING,
  `TIPO_RECURSO` STRING,
  `RECURSO_STAT` STRING,
  `RESULTADO` STRING,
  `CAUSA_RESULTADO` STRING,
  `FECHA_PRESENTACION_RECURSO` STRING,
  `NRO_PROCEDIMIENTO` STRING,
  `DESC_PROCEDIMIENTO` STRING,
  `REQER_NM` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/RecursosObjecion.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_recursos_objecion` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_recursos_objecion`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_remates` (
  `NRO_SICOP` STRING,
  `NUMERO_PROCEDIMIENTO` STRING,
  `FECHA_INVITACION` STRING,
  `CED_PROVEEDOR` STRING,
  `MONTO_PUJA` STRING,
  `MONEDA_PUJA` STRING,
  `FECHA_MOD` STRING,
  `MONTO_EST_LINEA` STRING,
  `CANT_EST` STRING,
  `MONEDA_ADJ` STRING,
  `MONTO_ADJ` STRING,
  `CANT_ADJ` STRING,
  `TIPO_CAMBIO_MONEDA` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/Remates.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_remates` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_remates`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_sancion_proveedores` (
  `NOMBRE_INSTITUCION` STRING,
  `CEDULA_INSTITUCION` STRING,
  `CODIGO_PRODUCTO` STRING,
  `DESCRIP_PRODUCTO` STRING,
  `CEDULA_PROVEEDOR` STRING,
  `NOMBRE_PROVEEDOR` STRING,
  `FECHA_REGISTRO` STRING,
  `TIPO_SANCION` STRING,
  `DESCR_SANCION` STRING,
  `INICIO_SANCION` STRING,
  `FINAL_SANCION` STRING,
  `ESTADO` STRING,
  `NO_RESOLUCION` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/SancionProveedores.csv'],
  field_delimiter = ',',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_sancion_proveedores` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_sancion_proveedores`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_sistema_evaluacion_ofertas` (
  `NRO_SICOP` STRING,
  `EVAL_ITEM_SEQNO` STRING,
  `FACTOR_EVAL` STRING,
  `PORC_EVAL` STRING,
  `FECHA_REGISTRO` STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://marketing_data_team/Explorer_data/sicop/raw/*/SistemaEvaluacionOfertas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE,
  max_bad_records = 100000,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_sistema_evaluacion_ofertas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_sistema_evaluacion_ofertas`;


CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_sistemas` (
  `NRO_SICOP` STRING,
  `NUMERO_LINEA` STRING,
  `NUMERO_PARTIDA` STRING,
  `DESC_LINEA` STRING,
  `CEDULA_INSTITUCION` STRING,
  `NRO_PROCEDIMIENTO` STRING,
  `TIPO_PROCEDIMIENTO` STRING,
  `FECHA_PUBLICACION` STRING,
  `MES_DESCARGA` STRING,
  `SOURCE_FILE` STRING
);
