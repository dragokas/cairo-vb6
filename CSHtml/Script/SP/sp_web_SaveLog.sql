if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_SaveLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_SaveLog]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

        select agn_id,
               agn_nombre   as Nombre,
               agn_codigo   as Codigo
        from Agenda 
  
        where (exists (select * from EmpresaAgenda where agn_id = Agenda.agn_id) or 1 = 1)

  select us_empresaex from usuario

 sp_web_SaveLog 1,2,'100',-1,1

 sp_web_SaveLog 1,'',0

*/

create procedure sp_web_SaveLog (
  @@pre_id          int,
  @@us_id           int,
  @@us_id2          int,
  @@descrip          varchar(255)  = ''
)
as
begin
  set nocount on

  insert into aaarbaweb..WebLog (us_id, us_id2, pre_id, wlog_descrip) values(@@us_id, @@us_id2, @@pre_id, @@descrip)

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

