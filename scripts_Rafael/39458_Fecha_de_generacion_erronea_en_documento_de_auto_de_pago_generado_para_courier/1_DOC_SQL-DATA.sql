USE documentos;

BEGIN TRANSACTION;  
BEGIN TRY  

UPDATE "plantilla_configuracion" SET "consulta"='DECLARE @FECHA DATE

SELECT TOP 1 @FECHA = tp.fecha_inicio
FROM coactivo c(NOLOCK)
JOIN proceso p(NOLOCK) ON p.id_proceso = c.id_proceso
JOIN trazabilidad_proceso tp(NOLOCK) ON tp.id_proceso = c.id_proceso
	AND tp.id_estado_proceso = 69
WHERE c.id_coactivo = :idCoactivo
ORDER BY c.id_coactivo DESC

SELECT c.numero_coactivo
	,CASE per.id_tipo_identificacion
		WHEN ''2''
			THEN pj.nombre_comercial
		ELSE Upper(CONCAT (
					per.nombre1
					,'' ''
					,per.nombre2
					,'' ''
					,per.apellido1
					,'' ''
					,per.apellido2
					))
		END AS nombreCompleto
	,CONCAT (
		p.numero_obligacion
		,''-''
		,Year(Sysdatetime())
		,''-''
		,(
			SELECT Max(t.numero_proceso)
			FROM titulo_credito t
			WHERE id_periodo_precoactivo = :periodo
			)
		,''-''
		,(
			SELECT Count(*)
			FROM titulo_credito
			WHERE id_periodo_precoactivo = :periodo
			)
		) AS consecutivo
	,per.numero_identificacion
	,Isnull(NULLIF(Isnull((
					SELECT TOP 1 Cast(u.direccion_de_entrega AS VARCHAR(200))
					FROM integracion_terceros..ubicabilidad_courier_validada u
					WHERE u.numero_identificacion = per.numero_identificacion
					ORDER BY fecha_registro DESC
					), dbo.Direccionpersona(per.id_persona, DEFAULT)), ''''), ''GUAYAS, GUAYAQUIL'') AS direccionDuedor
	,GETDATE() AS fechaActual
	,(
		SELECT CONCAT (
				Substring(f.titulo_obtenido, 1, 1)
				,Lower(Substring(f.titulo_obtenido, 2, Len(f.titulo_obtenido)))
				,'' ''
				,per.nombre1
				,'' ''
				,per.nombre2
				,'' ''
				,per.apellido1
				,'' ''
				,per.apellido2
				)
		FROM funcionario_coactivo f
			,persona per
		WHERE f.id_cargo = 1
			AND per.id_persona = f.id_persona
			AND f.fecha_inicio_vigencia <= CONVERT(DATE, @FECHA)
			AND f.fecha_final_vigencia >= CONVERT(DATE, @FECHA)
			OR (
				f.id_cargo = 1
				AND per.id_persona = f.id_persona
				AND f.fecha_inicio_vigencia <= CONVERT(DATE, @FECHA)
				AND f.fecha_final_vigencia IS NULL
				)
		) AS nombrefuncionario
	,(
		SELECT CONCAT (
				per.nombre1
				,'' ''
				,per.nombre2
				,'' ''
				,per.apellido1
				,'' ''
				,per.apellido2
				)
		FROM funcionario f
			,persona per
		WHERE per.id_persona = f.id_persona
			AND f.fecha_final_vigencia IS NULL
			AND f.id_cargo = 4
			AND f.id_subcargo = 3
		) AS nombrefuncionario2
	,(
		SELECT Max(fp.numero_imagen)
		FROM firma_persona fp(NOLOCK)
		INNER JOIN funcionario_coactivo f(NOLOCK) ON f.id_persona = fp.id_persona
		WHERE f.id_cargo = 1
			AND f.fecha_inicio_vigencia <= CONVERT(DATE, @FECHA)
			AND f.fecha_final_vigencia >= CONVERT(DATE, @FECHA)
			OR (
				f.id_cargo = 1
				AND f.fecha_inicio_vigencia <= CONVERT(DATE, @FECHA)
				AND f.fecha_final_vigencia IS NULL
				)
		) AS firma
	,(
		SELECT Max(fp.numero_imagen)
		FROM firma_persona fp(NOLOCK)
		INNER JOIN funcionario fu(NOLOCK) ON fu.id_persona = fp.id_persona
		WHERE fu.fecha_final_vigencia IS NULL
			AND fu.id_cargo = 4
			AND fu.id_subcargo = 3
		) AS firma2
	,ti.codigo
	,(
		SELECT Sum(valor_tasa)
		FROM periodo_precoactivo
		WHERE id_precoactivo = p.id_precoactivo
			AND estado_periodo <> ''ANULADO''
		) AS v
	,(
		SELECT [dbo].[Convertirnumeroletra]((
					SELECT Sum(valor_tasa)
					FROM periodo_precoactivo
					WHERE id_precoactivo = p.id_precoactivo
						AND estado_periodo <> ''ANULADO''
					), '''')
		) AS valorTotalLetras
	,(
		SELECT f.memo_nombramiento
		FROM funcionario_coactivo f
			,persona per
		WHERE f.id_cargo = 1
			AND per.id_persona = f.id_persona
			AND f.fecha_inicio_vigencia <= CONVERT(DATE, @FECHA)
			AND f.fecha_final_vigencia >= CONVERT(DATE, @FECHA)
			OR (
				f.id_cargo = 1
				AND per.id_persona = f.id_persona
				AND f.fecha_inicio_vigencia <= CONVERT(DATE, @FECHA)
				AND f.fecha_final_vigencia IS NULL
				)
		) AS memo
	,(
		SELECT f.fecha_nombramiento
		FROM funcionario_coactivo f
			,persona per
		WHERE f.id_cargo = 1
			AND per.id_persona = f.id_persona
			AND f.fecha_inicio_vigencia <= CONVERT(DATE, @FECHA)
			AND f.fecha_final_vigencia >= CONVERT(DATE, @FECHA)
			OR (
				f.id_cargo = 1
				AND per.id_persona = f.id_persona
				AND f.fecha_inicio_vigencia <= CONVERT(DATE, @FECHA)
				AND f.fecha_final_vigencia IS NULL
				)
		) AS fechaMemo
	,tp.fecha_inicio AS fecha3
	,(
		SELECT CONCAT (
				Substring(f.titulo_obtenido, 1, 1)
				,Substring(f.titulo_obtenido, 2, Len(f.titulo_obtenido))
				,'' ''
				,per.nombre1
				,'' ''
				,per.nombre2
				,'' ''
				,per.apellido1
				,'' ''
				,per.apellido2
				,'', Mgs''
				)
		FROM funcionario f
			,persona per
		WHERE f.id_cargo = 11
			AND per.id_persona = f.id_persona
			AND f.fecha_inicio_vigencia <= CONVERT(DATE, @FECHA)
			AND f.fecha_final_vigencia >= CONVERT(DATE, @FECHA)
			OR (
				f.id_cargo = 11
				AND per.id_persona = f.id_persona
				AND f.fecha_inicio_vigencia <= CONVERT(DATE, @FECHA)
				AND f.fecha_final_vigencia IS NULL
				)
		) AS nombrefuncionario3
	,p.placa_vehiculo AS placa
	,tim.nombre AS motivoRetencion
	,CASE 
		WHEN tim.articulo IS NULL
			THEN ''''
		WHEN tim.articulo <> ''''
			THEN CONCAT (
					''dispuesto en el ''
					,tim.articulo
					,'', ''
					)
		ELSE ''''
		END AS articulo
	,peri.numero_periodo
	,peri.fecha_inicio_periodo
	,peri.fecha_fin_periodo
	,peri.valor_tasa
	,CASE WHEN c.id_coactivo IN (2112641,2112641,2112646)
			THEN ''El presente documento sustituye cualquier otro emitido por el mismo concepto y hechos''
		ELSE ''''
		END AS textoMostrar
FROM precoactivo p
INNER JOIN coactivo c ON c.id_deudor = p.id_deudor
INNER JOIN trazabilidad_proceso tp(NOLOCK) ON tp.id_proceso = c.id_proceso
INNER JOIN periodo_precoactivo peri ON peri.id_precoactivo = p.id_precoactivo
INNER JOIN persona per ON per.id_persona = p.id_deudor
INNER JOIN tipo_identificacion_persona ti ON per.id_tipo_identificacion = ti.id_tipo_identificacion
LEFT JOIN persona_juridica pj(NOLOCK) ON pj.id_persona_juridica = per.id_persona
INNER JOIN motivo_inmovilizacion_vehiculo tim ON tim.id_motivo_inmovilizacion_vehiculo = p.motivo_retencion
INNER JOIN titulo_credito t ON t.id_periodo_precoactivo = peri.id_periodo
WHERE peri.fecha_notificacion_titulo IS NOT NULL
	AND peri.estado_periodo IN (
		''activo''
		,''inactivo''
		)
	AND peri.estado_notificacion = ''enviado''
	AND p.id_deudor = :deudor
	AND c.id_coactivo = :idCoactivo
	AND tp.id_estado_proceso = 69
	AND peri.id_periodo = :periodo
' WHERE "id_plantilla_config" in (10115,10148);


END TRY  
BEGIN CATCH  
    SELECT   
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_LINE() AS ErrorLine  
        ,ERROR_MESSAGE() AS ErrorMessage;  
  
    IF @@TRANCOUNT > 0  
        ROLLBACK TRANSACTION;  
END CATCH;  
  
IF @@TRANCOUNT > 0  
    COMMIT TRANSACTION;  
GO  
