/*
---------------------------------------------------------------------
Nombre: Ranking de venta por Centro de Costos
---------------------------------------------------------------------


DC_CSC_VEN_0110 1,'20000101','20100101',0,0,0,0,0,0,0,0,0,0,0,0,0,0
*/

if exists (select * from sysobjects where id = object_id(N'[dbo].[DC_CSC_VEN_0110]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DC_CSC_VEN_0110]


go
create procedure DC_CSC_VEN_0110 (

  @@us_id        int,
  @@Fini          datetime,
  @@Ffin          datetime,

  @@pro_id           varchar(255),
  @@cli_id           varchar(255),
  @@ven_id           varchar(255),
  @@cico_id           varchar(255),
  @@ccos_id           varchar(255),
  @@cpg_id           varchar(255),
  @@lp_id             varchar(255),
  @@ld_id             varchar(255),
  @@suc_id           varchar(255),
  @@doct_id           int,
  @@doc_id           varchar(255),
  @@mon_id           varchar(255),
  @@trans_id         varchar(255),
  @@emp_id           varchar(255)

)as 
begin

set nocount on

/*- ///////////////////////////////////////////////////////////////////////

SEGURIDAD SOBRE USUARIOS EXTERNOS

/////////////////////////////////////////////////////////////////////// */

declare @us_empresaEx tinyint
select @us_empresaEx = us_empresaEx from usuario where us_id = @@us_id


/*- ///////////////////////////////////////////////////////////////////////

INICIO PRIMERA PARTE DE ARBOLES

/////////////////////////////////////////////////////////////////////// */

declare @pro_id       int
declare @cli_id       int
declare @ven_id       int
declare @cico_id      int
declare @doc_id       int
declare @mon_id       int
declare @emp_id       int

declare @ccos_id      int
declare @cpg_id        int
declare @lp_id        int
declare @ld_id        int
declare @suc_id        int
declare @trans_id     int

declare @ram_id_provincia        int
declare @ram_id_cliente          int
declare @ram_id_vendedor         int
declare @ram_id_circuitoContable int
declare @ram_id_documento        int
declare @ram_id_moneda           int
declare @ram_id_empresa          int
declare @ram_id_centroCosto      int
declare @ram_id_condicionPago    int
declare @ram_id_listaPrecio      int
declare @ram_id_listaDescuento   int
declare @ram_id_sucursal         int
declare @ram_id_transporte       int

declare @clienteID       int
declare @clienteIDccosi int

declare @IsRaiz    tinyint

exec sp_ArbConvertId @@pro_id,       @pro_id out,        @ram_id_provincia out
exec sp_ArbConvertId @@cli_id,       @cli_id out,        @ram_id_cliente out
exec sp_ArbConvertId @@ven_id,       @ven_id out,        @ram_id_vendedor out
exec sp_ArbConvertId @@cico_id,      @cico_id out,       @ram_id_circuitoContable out
exec sp_ArbConvertId @@doc_id,       @doc_id out,        @ram_id_documento out
exec sp_ArbConvertId @@mon_id,       @mon_id out,        @ram_id_moneda out
exec sp_ArbConvertId @@emp_id,       @emp_id out,        @ram_id_empresa out
exec sp_ArbConvertId @@ccos_id,      @ccos_id out,       @ram_id_centroCosto out
exec sp_ArbConvertId @@cpg_id,        @cpg_id out,       @ram_id_condicionPago out
exec sp_ArbConvertId @@lp_id,        @lp_id out,         @ram_id_listaPrecio out
exec sp_ArbConvertId @@ld_id,        @ld_id out,         @ram_id_listaDescuento out
exec sp_ArbConvertId @@suc_id,       @suc_id out,       @ram_id_sucursal out
exec sp_ArbConvertId @@trans_id,     @trans_id out,     @ram_id_transporte out

exec sp_GetRptId @clienteID out
exec sp_GetRptId @clienteIDccosi out

if @ram_id_provincia <> 0 begin

--  exec sp_ArbGetGroups @ram_id_provincia, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_provincia, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_provincia, @clienteID 
  end else 
    set @ram_id_provincia = 0
end

if @ram_id_cliente <> 0 begin

--  exec sp_ArbGetGroups @ram_id_cliente, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_cliente, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_cliente, @clienteID 
  end else 
    set @ram_id_cliente = 0
end

if @ram_id_vendedor <> 0 begin

--  exec sp_ArbGetGroups @ram_id_vendedor, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_vendedor, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_vendedor, @clienteID 
  end else 
    set @ram_id_vendedor = 0
end

if @ram_id_circuitoContable <> 0 begin

--  exec sp_ArbGetGroups @ram_id_circuitoContable, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_circuitoContable, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_circuitoContable, @clienteID 
  end else 
    set @ram_id_circuitoContable = 0
end

if @ram_id_documento <> 0 begin

--  exec sp_ArbGetGroups @ram_id_documento, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_documento, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_documento, @clienteID 
  end else 
    set @ram_id_documento = 0
end

if @ram_id_moneda <> 0 begin

--  exec sp_ArbGetGroups @ram_id_moneda, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_moneda, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_moneda, @clienteID 
  end else 
    set @ram_id_moneda = 0
end

if @ram_id_empresa <> 0 begin

--  exec sp_ArbGetGroups @ram_id_empresa, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_empresa, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_empresa, @clienteID 
  end else 
    set @ram_id_empresa = 0
end

if @ram_id_centroCosto <> 0 begin

--  exec sp_ArbGetGroups @ram_id_centroCosto, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_centroCosto, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_centroCosto, @clienteID 
  end else 
    set @ram_id_centroCosto = 0
end

if @ram_id_condicionPago <> 0 begin

--  exec sp_ArbGetGroups @ram_id_condicionPago, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_condicionPago, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_condicionPago, @clienteID 
  end else 
    set @ram_id_condicionPago = 0
end

if @ram_id_listaPrecio <> 0 begin

--  exec sp_ArbGetGroups @ram_id_listaPrecio, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_listaPrecio, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_listaPrecio, @clienteID 
  end else 
    set @ram_id_listaPrecio = 0
end

if @ram_id_listaDescuento <> 0 begin

--  exec sp_ArbGetGroups @ram_id_listaDescuento, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_listaPrecio, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_listaDescuento, @clienteID 
  end else 
    set @ram_id_listaDescuento = 0
end

if @ram_id_sucursal <> 0 begin

--  exec sp_ArbGetGroups @ram_id_sucursal, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_sucursal, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_sucursal, @clienteID 
  end else 
    set @ram_id_sucursal = 0
end

if @ram_id_transporte <> 0 begin

--  exec sp_ArbGetGroups @ram_id_transporte, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_transporte, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_transporte, @clienteID 
  end else 
    set @ram_id_transporte = 0
end

/*- ///////////////////////////////////////////////////////////////////////

FIN PRIMERA PARTE DE ARBOLES

/////////////////////////////////////////////////////////////////////// */

create table #dc_csc_ven_0110 ( fv_id               int,
                                ccos_id             int,
                                Empresa              varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AI,
                                Moneda              varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AI,
                                [Centro de Costo]    varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AI,
                                Codigo              varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AI,
                                Neto                decimal(18,6),
                                IvaRi                decimal(18,6),
                                Importe              decimal(18,6),
                                Origen              decimal(18,6)
                              )


insert into #dc_csc_ven_0110

select 
    fv_id,
    fv.ccos_id,

    emp_nombre                          as Empresa,
    mon_nombre                          as Moneda,

    ccos_nombre                          as [Centro de costo],
    ccos_codigo                          as Codigo,

    fv_neto                             as Neto,
    fv_ivari                             as IvaRI,
    fv_total                             as Importe,
    fv_totalOrigen                       as Origen

from 

  FacturaVenta fv  inner join moneda      mon       on fv.mon_id   = mon.mon_id
                   inner join empresa     emp       on fv.emp_id   = emp.emp_id
                   inner join centroCosto ccos      on fv.ccos_id  = ccos.ccos_id
                   inner join cliente     cli       on fv.cli_id   = cli.cli_id
                   inner join documento   doc       on fv.doc_id   = doc.doc_id
where 

          fv_fecha >= @@Fini
      and  fv_fecha <= @@Ffin 

      -- Sin anuladas
      and fv.est_id <> 7

-- Validar usuario - empresa
      and (
            exists(select * from EmpresaUsuario where emp_id = doc.emp_id and us_id = @@us_id) or (@@us_id = 1)
          )
       and (
            exists(select * from UsuarioEmpresa where cli_id = fv.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
          )

/* -///////////////////////////////////////////////////////////////////////

INICIO SEGUNDA PARTE DE ARBOLES

/////////////////////////////////////////////////////////////////////// */

and   (cli.pro_id   = @pro_id   or @pro_id  =0)
and   (fv.cli_id     = @cli_id   or @cli_id  =0)
and   (cli.ven_id    = @ven_id   or @ven_id  =0)
and   (doc.cico_id   = @cico_id   or @cico_id  =0)
and   (fv.doc_id     = @doc_id   or @doc_id  =0)
and   (fv.mon_id     = @mon_id   or @mon_id  =0)
and   (fv.emp_id     = @emp_id   or @emp_id  =0)

and   (fv.ccos_id   = @ccos_id         or @ccos_id        =0)
and   (fv.cpg_id     = @cpg_id         or @cpg_id        =0)
and   (fv.lp_id     = @lp_id           or @lp_id          =0)

and   (fv.ld_id           = @ld_id     or @ld_id      =0)
and   (fv.suc_id           = @suc_id   or @suc_id    =0)
and   (fv.trans_id         = @trans_id or @trans_id  =0)

-- Arboles
and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 6 
                  and  rptarb_hojaid = cli.pro_id
                 ) 
           )
        or 
           (@ram_id_provincia = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 28 
                  and  rptarb_hojaid = fv.cli_id
                 ) 
           )
        or 
           (@ram_id_cliente = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 15 
                  and  rptarb_hojaid = cli.ven_id
                 ) 
           )
        or 
           (@ram_id_vendedor = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 1016 
                  and  rptarb_hojaid = doc.cico_id
                 ) 
           )
        or 
           (@ram_id_circuitoContable = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 4001 
                  and  rptarb_hojaid = fv.doc_id
                 ) 
           )
        or 
           (@ram_id_documento = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 12 
                  and  rptarb_hojaid = doc.mon_id
                 ) 
           )
        or 
           (@ram_id_moneda = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 1018 
                  and  rptarb_hojaid = doc.emp_id
                 ) 
           )
        or 
           (@ram_id_empresa = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 21 
                  and  rptarb_hojaid = fv.ccos_id
                 ) 
           )
        or 
           (@ram_id_centroCosto = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 1005 
                  and  rptarb_hojaid = fv.cpg_id
                 ) 
           )
        or 
           (@ram_id_condicionPago = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 27 
                  and  rptarb_hojaid = fv.lp_id
                 ) 
           )
        or 
           (@ram_id_listaPrecio = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 1006 
                  and  rptarb_hojaid = fv.ld_id
                 ) 
           )
        or 
           (@ram_id_listaDescuento = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 1007 
                  and  rptarb_hojaid = fv.suc_id
                 ) 
           )
        or 
           (@ram_id_sucursal = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 34 
                  and  rptarb_hojaid = fv.trans_id
                 ) 
           )
        or 
           (@ram_id_transporte = 0)
       )

select

    1                                   as orden_id,

    Empresa,
    Moneda,

    [Centro de costo],
    Codigo,

    sum(Neto)                           as Neto,
    sum(IvaRi)                           as IvaRI,
    sum(Importe)                         as Importe,
    sum(Origen)                          as Origen

from #dc_csc_ven_0110

group by     
    Empresa,
    Moneda,
    [Centro de costo],
    Codigo

union

select 
    1                                   as orden_id,

    emp_nombre                          as Empresa,
    mon_nombre                          as Moneda,

    ccos_nombre                          as [Centro de costo],
    ccos_codigo                          as Codigo,

    sum(fvi_neto)                       as Neto,
    sum(fvi_ivari)                       as IvaRI,
    sum(fvi_importe)                     as Importe,
    sum(fvi_importeOrigen)               as Origen

from 

  FacturaVenta fv  inner join moneda      mon       on fv.mon_id   = mon.mon_id
                   inner join empresa     emp       on fv.emp_id   = emp.emp_id
                   inner join centroCosto ccos      on fv.ccos_id  = ccos.ccos_id
                   inner join cliente     cli       on fv.cli_id   = cli.cli_id
                   inner join documento   doc       on fv.doc_id   = doc.doc_id
                   inner join FacturaVentaItem fvi  on fv.fv_id    = fvi.fv_id
where 

          fv_fecha >= @@Fini
      and  fv_fecha <= @@Ffin 

      -- Sin anuladas
      and fv.est_id <> 7

      and fvi_pendiente > 0

      and not exists (select * from #dc_csc_ven_0110 where fv_id = fvi.fv_id and ccos_id = fvi.ccos_id)

-- Validar usuario - empresa
      and (
            exists(select * from EmpresaUsuario where emp_id = doc.emp_id and us_id = @@us_id) or (@@us_id = 1)
          )
       and (
            exists(select * from UsuarioEmpresa where cli_id = fv.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
          )

/* -///////////////////////////////////////////////////////////////////////

INICIO SEGUNDA PARTE DE ARBOLES

/////////////////////////////////////////////////////////////////////// */

and   (cli.pro_id   = @pro_id   or @pro_id  =0)
and   (fv.cli_id     = @cli_id   or @cli_id  =0)
and   (cli.ven_id   = @ven_id   or @ven_id  =0)
and   (doc.cico_id   = @cico_id   or @cico_id  =0)
and   (fv.doc_id     = @doc_id   or @doc_id  =0)
and   (fv.mon_id     = @mon_id   or @mon_id  =0)
and   (fv.emp_id     = @emp_id   or @emp_id  =0)

and   (fvi.ccos_id   = @ccos_id         or @ccos_id        =0)
and   (fv.cpg_id     = @cpg_id         or @cpg_id        =0)
and   (fv.lp_id     = @lp_id           or @lp_id          =0)

and   (fv.ld_id           = @ld_id     or @ld_id      =0)
and   (fv.suc_id           = @suc_id   or @suc_id    =0)
and   (fv.trans_id         = @trans_id or @trans_id  =0)

-- Arboles
and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 6 
                  and  rptarb_hojaid = cli.pro_id
                 ) 
           )
        or 
           (@ram_id_provincia = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 28 
                  and  rptarb_hojaid = fv.cli_id
                 ) 
           )
        or 
           (@ram_id_cliente = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 15 
                  and  rptarb_hojaid = cli.ven_id
                 ) 
           )
        or 
           (@ram_id_vendedor = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 1016 
                  and  rptarb_hojaid = doc.cico_id
                 ) 
           )
        or 
           (@ram_id_circuitoContable = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 4001 
                  and  rptarb_hojaid = fv.doc_id
                 ) 
           )
        or 
           (@ram_id_documento = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 12 
                  and  rptarb_hojaid = fv.mon_id
                 ) 
           )
        or 
           (@ram_id_moneda = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 1018 
                  and  rptarb_hojaid = fv.emp_id
                 ) 
           )
        or 
           (@ram_id_empresa = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 21 
                  and  rptarb_hojaid = fvi.ccos_id
                 ) 
           )
        or 
           (@ram_id_centroCosto = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 1005 
                  and  rptarb_hojaid = fv.cpg_id
                 ) 
           )
        or 
           (@ram_id_condicionPago = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 27 
                  and  rptarb_hojaid = fv.lp_id
                 ) 
           )
        or 
           (@ram_id_listaPrecio = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 1006 
                  and  rptarb_hojaid = fv.ld_id
                 ) 
           )
        or 
           (@ram_id_listaDescuento = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 1007 
                  and  rptarb_hojaid = fv.suc_id
                 ) 
           )
        or 
           (@ram_id_sucursal = 0)
       )

and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 34 
                  and  rptarb_hojaid = fv.trans_id
                 ) 
           )
        or 
           (@ram_id_transporte = 0)
       )

group by     
      emp_nombre,
      mon_nombre,
      ccos.ccos_nombre,
      ccos.ccos_codigo

end
go
