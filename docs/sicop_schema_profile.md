# Perfil de CSV SICOP 2022-2026

Carpeta base: `/Users/nancyrodriguez/Documents/Contraloria/bases`
Meses descargados: 53 (202201 a 202605)

## Archivos y variables

### AdjudicacionesFirme.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 2
- Filas aproximadas acumuladas: 340,035
- Columnas (6): NRO_SICOP, NRO_ACTO, FECHA_ADJ_FIRME, PERMITE_RECURSOS, DESIERTO, FECHA_REV

### Contratos.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 3
- Filas aproximadas acumuladas: 216,277
- Columnas (21): NRO_CONTRATO, NRO_CONTRATO_WEB, SECUENCIA, NUMERO_PROCEDIMIENTO, CEDULA_PROVEEDOR, NRO_SICOP, CEDULA_INSTITUCION, FECHA_INI_PRORR, FECHA_FIN_PRORR, VIGENCIA, MONEDA, FECHA_INI_SUSP, PLAZO_SUSP, FECHA_REINI_CONT, FECHA_MODIFICACION, TIPO_CONTRATO, TIPO_MODIFICACION, FECHA_NOTIFICACION, FECHA_ELABORACION, TIPO_AUTORIZACION, TIPO_DISMINUCION

### DetalleCarteles.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 2
- Filas aproximadas acumuladas: 156,685
- Columnas (15): NRO_SICOP, CEDULA_INSTITUCION, FECHA_PUBLICACION, NRO_PROCEDIMIENTO, TIPO_PROCEDIMIENTO, MODALIDAD_PROCEDIMIENTO, DES_EXCEPCION, MONTO_EST, FECHA_MOD, CARTEL_STAT, CARTEL_NM, FECHAH_APERTURA, CODIGO_BPIP, CLAS_OBJ, COD_EXCEPCION

### DetalleLineaCartel.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 1
- Filas aproximadas acumuladas: 601,796
- Columnas (11): NRO_SICOP, NUMERO_LINEA, NUMERO_PARTIDA, CANTIDAD_SOLICITADA, PRECIO_UNITARIO_ESTIMADO, TIPO_MONEDA, TIPO_CAMBIO_CRC, TIPO_CAMBIO_DOLAR, CODIGO_IDENTIFICACION, MONTO_RESERVADO, DESC_LINEA

### FechaPorEtapas.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 2
- Filas aproximadas acumuladas: 895,409
- Columnas (27): NRO_SICOP, NUMERO_PROCEDIMIENTO, CARTEL_SEQ, PARTIDA, LINEA, PUBLICACION, FECHA_1RA_SOL_PAGO, FECHA_ULT_SOL_PAGO, FECHA_RESUL_PAGO, SOLICITUD_APROBACION_CONTRATO, RESPUESTA_APROBACION_CONTRATO, FECHA_NOTIFICACION, FECHA_1RA_SOL_RECEPCION, FECHA_1RA_SOL_RECEP_PROVI, FECHA_ULT_SOL_RECEP_DEFI, RESPUESTA_RECOM_ADJUD, SOLICITUD_ADJUD, RESPUESTA_ADJUD, ADJUDICACION_FIRME, FECHA_RESUL_PAGO_ESP_FISCALES, FECHA_ELABORACION_CONTRATO, FECHA_APERTURA, SOLICITUD_ESTUDIOS_TECNICOS, COMUNICACION, SOLICITUD_PAGO_ESP_FISCALES, RESPUESTA_ESTUDIOS_TECNICOS, SOLICITUD_RECOM_ADJUD

### FuncionariosInhibicion.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 1
- Filas aproximadas acumuladas: 301,197
- Columnas (7): CED_INSTITUCION, CED_FUNCIONARIO, NOM_FUNCIONARIO, FECHA_INICIO, FECHA_FIN, ESTADO, fecha_registro

### Garantias.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 2
- Filas aproximadas acumuladas: 273,558
- Columnas (17): NRO_SICOP, NUMERO_PROCEDIMIENTO, DESCRIPCION_PROCEDIMIENTO, TIPO_PROCEDIMIENTO, NOMBRE_INSTITUCION, CEDULA_INSTITUCION, fecha_registro, nro_garantia, ced_garante, gara_seq, NOMBRE_PROVEEDOR, CEDULA_PROVEEDOR, TIPO_GARANTIA, MONTO, ESTADO, GARANTIA_NM, VIGENCIA

### InstitucionesRegistradas.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 2
- Filas aproximadas acumuladas: 24,509
- Columnas (5): CEDULA, NOMBRE_INSTITUCION, ZONA_GEO_INST, FECHA_INGRESO, FECHA_MOD

### InvitacionProcedimiento.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 2
- Filas aproximadas acumuladas: 52,513,539
- Columnas (8): SECUENCIA, CED_INSTITUCION, INSTITUCION, NRO_SICOP, CEDULA_PROVEEDOR, NOMBRE_PROVEEDOR, NUMERO_PROCEDIMIENTO, FECHA_INVITACION

### LineasAdjudicadas.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 2
- Filas aproximadas acumuladas: 191,081
- Columnas (15): NRO_SICOP, NRO_OFERTA, CODIGO_PRODUCTO, NRO_LINEA, NRO_ACTO, CEDULA_PROVEEDOR, ACARREOS, TIPO_CAMBIO_CRC, TIPO_CAMBIO_DOLAR, CANTIDAD_ADJUDICADA, PRECIO_UNITARIO_ADJUDICADO, TIPO_MONEDA, DESCUENTO, IVA, OTROS_IMPUESTOS

### LineasContratadas.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 2
- Filas aproximadas acumuladas: 173,819
- Columnas (22): NRO_SICOP, NRO_LINEA_CONTRATO, NRO_LINEA_CARTEL, NRO_CONTRATO, SECUENCIA, CEDULA_PROVEEDOR, cantidad_aumentada, cantidad_disminuida, monto_aumentado, monto_disminuido, OTROS_IMPUESTOS, ACARREOS, TIPO_CAMBIO_CRC, TIPO_CAMBIO_DOLAR, NRO_ACTO, DESC_PRODUCTO, CODIGO_PRODUCTO, CANTIDAD_CONTRATADA, PRECIO_UNITARIO, TIPO_MONEDA, DESCUENTO, IVA

### LineasOfertadas.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 3
- Filas aproximadas acumuladas: 542,870
- Columnas (14): NRO_SICOP, NRO_OFERTA, NRO_LINEA, CODIGO_PRODUCTO, CANTIDAD_OFERTADA, PRECIO_UNITARIO_OFERTADO, TIPO_CAMBIO_DOLAR, TIPO_MONEDA, DESCUENTO, IVA, OTROS_IMPUESTOS, ACARREOS, TIPO_CAMBIO_CRC, CODIGO_PRODUCTO_CL

### LineasRecibidas.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 2
- Filas aproximadas acumuladas: 307,637
- Columnas (15): NRO_SICOP, NRO_CONTRATO, SECUENCIA, NRO_RECEP_PROVISIONAL, ESTADO_RECEP_PROVISIONAL, NRO_RECEP_DEFINITIVA, precio, dias_adelanto_atraso, fecha_recepcion_Definitiva, ESTADO_RECEP_DEFINITIVA, NRO_LINEA, ENTREGA, CODIGO_PRODUCTO, CANTIDAD_REAL_RECIBIDA, desc_producto

### Ofertas.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 1
- Filas aproximadas acumuladas: 1,085,426
- Columnas (6): NRO_SICOP, NRO_OFERTA, CEDULA_PROVEEDOR, FECHA_PRESENTA_OFERTA, TIPO_OFERTA, ID_CONSORCIO

### OrdenPedido.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 3
- Filas aproximadas acumuladas: 1,824,726
- Columnas (22): NRO_SICOP, NUMERO_PROCEDIMIENTO, NRO_CONTRATO, CONTRACT_NO, SECUENCIA_CONTRATO, TOTAL_ORDEN, FECHA_PROVEEDOR_RECIBE_ORDEN, LINEA_ORD_PEDIDO, FECHA_REC_PEDIDO, SECUENCIA, FECHA_PROV_RECIBE_ORDEN, USD_MONT, NRO_ORDEN, MONEDA_ORDEN, FECHA_NOTIFICACION_ORDEN, FECHA_ELABORACION_ORDEN, TOTALESTIMADO, ESTADO_ORDEN, DESC_PROCEDIMIENTO, CEDULAPROVEEDOR, NOMBRE_PROVEEDOR, FECHAREGISTRO

### ProcedimientoADM.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 1
- Filas aproximadas acumuladas: 101
- Columnas (10): NRO_SICOP, NUMERO_PROCEDIMIENTO, NOMBRE_PROVEEDOR, NUMERO_PA, NOMBRE_INSTITUCION, CEDULA_INSTITUCION, CEDULA_PROVEEDOR, FECHA_NOTIFICACION, INHAB_APERC, MULTA_CAUSULA

### ProcedimientoAdjudicacion.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 3
- Filas aproximadas acumuladas: 164,791
- Columnas (30): CEDULA, INSTITUCION, ANO, NUMERO_PROCEDIMIENTO, DESCR_PROCEDIMIENTO, LINEA, NRO_SICOP, TIPO_PROCEDIMIENTO, MODALIDAD_PROCEDIMIENTO, fecha_rev, CEDULA_PROVEEDOR, NOMBRE_PROVEEDOR, PERFIL_PROV, CEDULA_REPRESENTANTE, REPRESENTANTE, OBJETO_GASTO, MONEDA_ADJUDICADA, MONTO_ADJU_LINEA, MONTO_ADJU_LINEA_CRC, MONTO_ADJU_LINEA_USD, FECHA_ADJUD_FIRME, FECHA_SOL_CONTRA, PROD_ID, DESCR_BIEN_SERVICIO, CANTIDAD, UNIDAD_MEDIDA, MONTO_UNITARIO, MONEDA_PRECIO_EST, FECHA_SOL_CONTRA_CL, PROD_ID_CL

### Proveedores.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 2
- Filas aproximadas acumuladas: 2,463,031
- Columnas (9): CEDULA_PROVEEDOR, NOMBRE_PROVEEDOR, TIPO_PROVEEDOR, TAMAÑO_PROVEEDOR, FECHA_CONSTITUCION, FECHA_EXPIRACION, zona_geo_prov, fecha_registro, fecha_mod

### ReajustePrecios.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 2
- Filas aproximadas acumuladas: 3,804
- Columnas (24): NRO_SICOP, NUMERO_PROCEDIMIENTO, NOMBRE_INSTITUCION, CEDULA_INSTITUCION, CEDULA_PROVEEDOR, NOMBRE_PROVEEDOR, FECHA_INICIO, FECHA_FIN, MESES_APP, DIAS_APP, TIPO_MONEDA, MONTO_TOTAL, PRECIO_UNITARIO, NUMERO_REAJUSTE, PRECIO_ANT_ULT_RJ, MONTO_REAJUSTE, NUEVO_PRECIO, PORC_INCR_ULT_RJ, FECHA_ELABORACION, CODIGO_PRODUCTO, DES_PRODUCTO, NRO_CONTRATO, NRO_LINEA_CONTRATO, CANTIDAD_CONTRATADA

### Recepciones.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 1
- Filas aproximadas acumuladas: 122,467
- Columnas (10): NRO_SICOP, NRO_CONTRATO, NRO_RECEP_DEFINITIVA, FECHA_RECEP_DEFINITIVA, nro_procedimiento, cedula_proveedor, cedula_institucion, moneda, nombre_proveedor, fecha_ent_ini

### RecursosObjecion.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 3
- Filas aproximadas acumuladas: 61,240
- Columnas (13): NRO_RECURSO, CEDULA_PROVEEDOR, NRO_SICOP, NRO_ACTO, LINEA_OBJETADA, TIPO_RECURSO, recurso_stat, RESULTADO, CAUSA_RESULTADO, FECHA_PRESENTACION_RECURSO, nro_procedimiento, desc_procedimiento, reqer_nm

### Remates.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 3
- Filas aproximadas acumuladas: 1,246,476
- Columnas (13): NRO_SICOP, NUMERO_PROCEDIMIENTO, FECHA_INVITACION, CED_PROVEEDOR, MONTO_PUJA, MONEDA_PUJA, fecha_mod, MONTO_EST_LINEA, CANT_EST, MONEDA_ADJ, MONTO_ADJ, CANT_ADJ, TIPO_CAMBIO_MONEDA

### SancionProveedores.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ',': 53
- Variantes de encabezado: 2
- Filas aproximadas acumuladas: 2,586
- Columnas (13): NOMBRE_INSTITUCION, CEDULA_INSTITUCION, CODIGO_PRODUCTO, DESCRIP_PRODUCTO, CEDULA_PROVEEDOR, NOMBRE_PROVEEDOR, fecha_registro, TIPO_SANCION, DESCR_SANCION, INICIO_SANCION, FINAL_SANCION, ESTADO, NO_RESOLUCION

### SistemaEvaluacionOfertas.csv
- Meses: 53 (202201 a 202605)
- Separador detectado: ';': 53
- Variantes de encabezado: 1
- Filas aproximadas acumuladas: 1,147,549
- Columnas (5): NRO_SICOP, EVAL_ITEM_SEQNO, FACTOR_EVAL, PORC_EVAL, fecha_registro

### Sistemas.csv
- Meses: 42 (202212 a 202605); faltan: 202201, 202202, 202203, 202204, 202205, 202206, 202207, 202208, 202209, 202210, 202211
- Separador detectado: ',': 22, ';': 20
- Variantes de encabezado: 1
- Filas aproximadas acumuladas: 639,963
- Columnas (8): NRO_SICOP, NUMERO_LINEA, NUMERO_PARTIDA, DESC_LINEA, CEDULA_INSTITUCION, NRO_PROCEDIMIENTO, TIPO_PROCEDIMIENTO, FECHA_PUBLICACION
