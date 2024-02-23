USE [Documentos]

BEGIN TRANSACTION; 
  
BEGIN TRY

INSERT INTO [dbo].[estado_proceso]
           ([id_estado_proceso]
           ,[codigo]
           ,[nombre]
           ,[sigla]
           ,[estado]
           ,[descripcion]
           ,[id_tipo_proceso])
     VALUES
           ( 139,
           '139',
           'ACTA RESORTEO',
           null,
            1,
            'ACTA RESORTEO',
            1)


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