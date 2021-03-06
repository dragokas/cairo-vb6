SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_Web_ReportsGetForUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_Web_ReportsGetForUser]
GO

/*

select * from usuario

sp_Web_ReportsGetForUser 1,'Ventas,Compras'

*/

create procedure sp_Web_ReportsGetForUser
(
  @@us_id           int,
  @@section         varchar(255)
) 
as
begin

  /* select tbl_id,tbl_nombrefisico from tabla where tbl_nombrefisico like '%informe%'*/
  exec sp_HistoriaUpdate 7001, 0, @@us_id, 1, @@section

  set nocount on

  create table #Informes (
                          per_id int,
                          pre_id int
                          )

  insert into #Informes exec SP_SecGetPermisosXUsuario @@us_id, 1

  select 
      distinct
      rpt_id,
      rpt_nombre,
      inf_modulo,
      rpt_descrip

  from reporte r inner join informe i    on r.inf_id = i.inf_id
                 inner join #Informes i2 on i.pre_id = i2.pre_id

  where (us_id = @@us_id or @@us_id = 0)
    and charindex(inf_modulo,@@section,1)<>0

  order by inf_modulo, rpt_nombre

end
go
set quoted_identifier off 
go
set ansi_nulls on 
go

