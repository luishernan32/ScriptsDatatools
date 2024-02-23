USE [Documentos]

BEGIN TRANSACTION; 
  
BEGIN TRY

UPDATE documentos..plantilla_configuracion
SET    consulta=   'DECLARE @id_funcionario INTEGER= NULL; 


SELECT TOP 1 @id_funcionario = ar.id_funcionario
FROM   circulemos2.dbo.proceso (nolock) pr
       INNER JOIN circulemos2.dbo.trazabilidad_proceso (nolock) tp
               ON pr.id_proceso = pr.id_proceso
                  AND tp.id_estado_proceso = 139
       INNER JOIN circulemos2.dbo.acta_resorteo ar (nolock)
               ON ar.id_trazabilidad_proceso = tp.id_trazabilidad_proceso
WHERE  pr.id_proceso = :idProceso
ORDER  BY tp.id_trazabilidad_proceso DESC

SELECT p.numero_proceso,
       CASE pe.id_tipo_identificacion
         WHEN ''2'' THEN pj.nombre_comercial
         ELSE Upper(Concat (pe.nombre1, '' '', pe.nombre2, '' '', pe.apellido1, '' '',
              pe.apellido2))
       END                                       AS nombreCompleto,
       dbo.Correopersona(pe.id_persona)          AS correos,
       p.fecha_inicio,
       (SELECT Upper(Concat(PER.nombre1, '' '', per.nombre2, '' '', per.apellido1,
                     '' '',
                             per.apellido2))
        FROM   trazabilidad_proceso tp (nolock)
               JOIN usuario_persona up (nolock)
                 ON up.id_usuario = tp.id_usuario
               JOIN persona per (nolock)
                 ON up.id_persona = per.id_persona
        WHERE  tp.id_estado_proceso = 6
               AND tp.id_proceso = :idProceso)   AS nombreUsuario,
       cv.placa_vehiculo,
        CASE
         WHEN @id_funcionario IS NULL THEN
         Concat(perd.nombre1, '' '', perd.nombre2, '' '',
         perd.apellido1, '' '',
         perd.apellido2)
         ELSE (SELECT Concat(p.nombre1, '' '', p.nombre2, '' '', p.apellido1, '' '',
                      p.apellido2)
               FROM   funcionario f (nolock)
                      JOIN persona p (nolock)
                        ON f.id_persona = p.id_persona
               WHERE  f.id_funcionario = @id_funcionario)
       END                                       AS nombreAbogadoFirma,
       car.nombre                                AS NombreCargo,
       CASE
         WHEN @id_funcionario IS NULL THEN (SELECT Max(numero_imagen)
                                            FROM   firma_persona fpe (nolock)
                                            WHERE
         fpe.id_persona = perd.id_persona)
         ELSE (SELECT Max(numero_imagen)
               FROM   funcionario f (nolock)
                      JOIN persona per (nolock)
                        ON per.id_persona = f.id_persona
                      JOIN firma_persona fpe (nolock)
                        ON fpe.id_persona = per.id_persona
               WHERE  f.id_funcionario = @id_funcionario)
       END                                       AS Firma,
       CASE
         WHEN @id_funcionario IS NULL THEN fu.memo_nombramiento
         ELSE (SELECT f.memo_nombramiento
               FROM   funcionario f (nolock)
               WHERE  f.id_funcionario = @id_funcionario)
       END                                       AS memo_nombramiento,
       CASE
         WHEN @id_funcionario IS NULL THEN fu.fecha_nombramiento
         ELSE (SELECT f.fecha_nombramiento
               FROM   funcionario f (nolock)
               WHERE  f.id_funcionario = @id_funcionario)
       END                                       AS fecha_nombramiento,
       (SELECT Concat(f.titulo_obtenido, '' '', p.nombre1, '' '', p.nombre2, '' '',
               p.apellido1, '' '',
                       p.apellido2)
        FROM   funcionario f (nolock)
               JOIN persona p (nolock)
                 ON f.id_persona = p.id_persona
        WHERE  id_cargo = 11
               AND fecha_final_vigencia IS NULL) AS nombreDirector
FROM   proceso p (nolock)
       JOIN comparendo_proceso cp (nolock)
         ON cp.id_proceso = p.id_proceso
       JOIN comparendo co (nolock)
         ON co.cicomparendo = cp.cicomparendo
       LEFT JOIN comparendo_vehiculo cv (nolock)
              ON cv.id_comparendo_vehiculo = co.cicomparendo
       JOIN participante_proceso pp (nolock)
         ON pp.id_proceso = p.id_proceso
       JOIN persona pe (nolock)
         ON pe.id_persona = pp.id_persona
       LEFT JOIN persona_juridica pj (nolock)
              ON pj.id_persona_juridica = pe.id_persona
       JOIN trazabilidad_proceso tp (nolock)
         ON tp.id_proceso = p.id_proceso
       JOIN usuario_persona up (nolock)
         ON up.id_usuario = tp.id_usuario
       JOIN persona per (nolock)
         ON per.id_persona = up.id_persona
       JOIN funcionario fu (nolock)
         ON fu.id_funcionario = (SELECT id_funcionario
                                 FROM   evaluar_impugnacion (nolock)
                                 WHERE  id_trazabilidad_proceso =
                                        (SELECT trei.id_trazabilidad_proceso
                                         FROM   evaluar_impugnacion eimp (nolock
                                                )
                                        INNER JOIN trazabilidad_proceso trei (nolock)
                                                ON trei.id_trazabilidad_proceso
                                                   =
                                                   eimp.id_trazabilidad_proceso
                                                                   WHERE
                                        trei.id_trazabilidad_proceso = (SELECT
                                        fiei.*
                                                                        FROM
                                        (SELECT
                                Max(tpei2.id_trazabilidad_proceso) AS
                                idTraza
                                                                FROM
                                evaluar_impugnacion eimp2 (nolock)
                                INNER JOIN trazabilidad_proceso tpei2 (nolock)
                                ON tpei2.id_trazabilidad_proceso =
                                eimp2.id_trazabilidad_proceso
                                INNER JOIN proceso pei (nolock)
                                ON pei.id_proceso = tpei2.id_proceso
                                WHERE  pei.id_proceso =
                                     :idProceso) fiei
                                )))
       JOIN cargo car (nolock)
         ON car.id_cargo = fu.id_cargo
       JOIN persona perd (nolock)
         ON perd.id_persona = fu.id_persona
WHERE  p.id_proceso = :idProceso
       AND co.id_estado_comparendo != 14
       AND tp.id_estado_proceso = 10
       AND pp.id_tipo_participante = 2 '               
	   
WHERE  id_plantilla_config=10196  --COA_CP



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