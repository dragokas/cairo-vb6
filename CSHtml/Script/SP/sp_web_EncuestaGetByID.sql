SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_EncuestaGetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_EncuestaGetByID]
GO


-- sp_web_EncuestaGetByID 2

create Procedure sp_web_EncuestaGetByID
(
  @@ec_id       int
)
as
begin

  -- Devuelve todos los datos del articulo, inclusive el nombre del estado, tipo y autor

  Select 
          ec_id, 
          ec_nombre, 
          ec_descrip, 
          ec_fechaDesde, 
          ec_fechaHasta,
          ec_anonimo,
          activo

  from 
        encuesta
  where 
      ec_id = @@ec_id

end

go
set quoted_identifier off 
go
set ansi_nulls on 
go

