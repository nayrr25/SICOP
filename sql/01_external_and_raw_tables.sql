
CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_adjudicaciones_firme`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/AdjudicacionesFirme.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_adjudicaciones_firme` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_adjudicaciones_firme`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_contratos`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/Contratos.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_contratos` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_contratos`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_detalle_carteles`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/DetalleCarteles.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_detalle_carteles` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_detalle_carteles`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_detalle_linea_cartel`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/DetalleLineaCartel.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_detalle_linea_cartel` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_detalle_linea_cartel`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_fecha_por_etapas`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/FechaPorEtapas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_fecha_por_etapas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_fecha_por_etapas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_funcionarios_inhibicion`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/FuncionariosInhibicion.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_funcionarios_inhibicion` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_funcionarios_inhibicion`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_garantias`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/Garantias.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_garantias` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_garantias`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_instituciones_registradas`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/InstitucionesRegistradas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_instituciones_registradas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_instituciones_registradas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_invitacion_procedimiento`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/InvitacionProcedimiento.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_invitacion_procedimiento` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_invitacion_procedimiento`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_adjudicadas`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/LineasAdjudicadas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_adjudicadas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_adjudicadas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_contratadas`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/LineasContratadas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_contratadas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_contratadas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_ofertadas`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/LineasOfertadas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_ofertadas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_ofertadas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_recibidas`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/LineasRecibidas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_lineas_recibidas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_lineas_recibidas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_ofertas`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/Ofertas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_ofertas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_ofertas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_orden_pedido`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/OrdenPedido.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_orden_pedido` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_orden_pedido`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_procedimiento_adm`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/ProcedimientoADM.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_procedimiento_adm` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_procedimiento_adm`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_procedimiento_adjudicacion`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/ProcedimientoAdjudicacion.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_procedimiento_adjudicacion` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_procedimiento_adjudicacion`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_proveedores`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/Proveedores.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_proveedores` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_proveedores`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_reajuste_precios`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/ReajustePrecios.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_reajuste_precios` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_reajuste_precios`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_recepciones`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/Recepciones.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_recepciones` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_recepciones`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_recursos_objecion`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/RecursosObjecion.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_recursos_objecion` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_recursos_objecion`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_remates`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/Remates.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_remates` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_remates`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_sancion_proveedores`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/SancionProveedores.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_sancion_proveedores` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_sancion_proveedores`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_sistema_evaluacion_ofertas`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/SistemaEvaluacionOfertas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_sistema_evaluacion_ofertas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_sistema_evaluacion_ofertas`;


CREATE OR REPLACE EXTERNAL TABLE `fifco-marketing-dev.ExploracionDataTeam.ext_sistemas`
OPTIONS (
  format = 'CSV',
  uris = ['gs://fifco-marketing-dev-sicop-raw/sicop/raw/*/Sistemas.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  autodetect = TRUE,
  encoding = 'UTF-8'
);

CREATE OR REPLACE TABLE `fifco-marketing-dev.ExploracionDataTeam.raw_sistemas` AS
SELECT
  *,
  REGEXP_EXTRACT(_FILE_NAME, r'/([0-9]{6})/[^/]+$') AS MES_DESCARGA,
  _FILE_NAME AS SOURCE_FILE
FROM `fifco-marketing-dev.ExploracionDataTeam.ext_sistemas`;
