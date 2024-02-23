USE [Documentos]
BEGIN TRANSACTION; 
  
BEGIN TRY

INSERT INTO [dbo].[proceso]
           ([id_proceso]
           ,[nombre_proceso]
           ,[descripcion_proceso]
           ,[id_proceso_padre]
           ,[codigo_proceso])
     VALUES
           (25,
           'Acta de Resorteo',
           'Acta de Resorteo',
		   null,
           '25')

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