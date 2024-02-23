BEGIN TRANSACTION;  
  
BEGIN TRY

set IDENTITY_INSERT estado_embargo ON

insert into estado_embargo(id_estado_embargo,nombre,sigla,estado,codigo,descripcion) values(6,'Dispuesto bloqueado impugnacion',null,1,6,'Dispuesto bloqueado impugnacion')

insert into estado_embargo(id_estado_embargo,nombre,sigla,estado,codigo,descripcion) values(7,'Cerrado Anulado',null,1,7,'Cerrado Anulado')

set IDENTITY_INSERT estado_embargo OFF

insert into web_services values (149,1,149,'Actualizar Estado Embargo Impugnacion',1,'Actualiza el estado del embargo cuando se hace un fallo',
'http://sogit-app.datatools.local:8080/CoactivoWEB/rest/actualizarEstadoEmbargoImpugnacion','http://sogit-app.datatools.local:8080/CoactivoWEB/rest/actualizarEstadoEmbargoImpugnacion')

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