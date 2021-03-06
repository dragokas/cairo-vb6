SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_DepartamentosXUsuario]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_DepartamentosXUsuario]
GO

/*

  select * from usuariodepartamento

insert into usuariodepartamento (usdpto_id,us_id,dpto_id,modifico)values(125,10,11,1)

 sp_web_DepartamentosXUsuario 1

*/

create Procedure sp_web_DepartamentosXUsuario
(
  @@us_id       int
)
as
begin

  /* select tbl_id,tbl_nombrefisico from tabla where tbl_nombrefisico like '%departamento%'*/
  exec sp_HistoriaUpdate 1015, 0, @@us_id, 1

  declare @us_id_bb int
  set @us_id_bb = 0

  -- Biblioteca virtual
  if @@us_id / 1000000 = 250 begin

    set @@us_id = @@us_id - 250000000
    set @us_id_bb = -250
  end

  Select 
          dpto.dpto_id, 
          dpto_nombre
  from 
        Departamento dpto 
  where 
              exists(select per_id from Permiso  
                     where     pre_id = pre_id_verdocumentos
                          and ( 
                                us_id = @@us_id
                              or
                                exists (select us_id from UsuarioRol where rol_id = Permiso.rol_id and us_id = @@us_id)
                              )
                     )
          -- La biblioteca solo se ve cuando entro por el usurio bibioteca
          and (not exists(select us_id from UsuarioDepartamento where us_id = -250 and @us_id_bb = 0 and dpto_id = dpto.dpto_id) or @us_id_bb = -250)
          and (exists(select us_id from UsuarioDepartamento where us_id = @us_id_bb and dpto_id = dpto.dpto_id) or @us_id_bb = 0)
  order by dpto_nombre              
end
go
set quoted_identifier off 
go
set ansi_nulls on 
go

