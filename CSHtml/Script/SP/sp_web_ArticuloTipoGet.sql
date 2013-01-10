SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_ArticuloTipoGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_ArticuloTipoGet]
GO

/*

sp_web_ArticuloTipoGet 

*/

create procedure sp_web_ArticuloTipoGet

as
begin

  select 

        wartt_id,
        wartt_nombre          as Nombre 

  from webArticuloTipo

end
go
set quoted_identifier off 
go
set ansi_nulls on 
go

