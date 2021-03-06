/*
---------------------------------------------------------------------
Nombre: Documentos de Venta Pendientes
---------------------------------------------------------------------


DC_CSC_VEN_0040 1,'20000101','20100101',0,0,0,0,0,0,0,0,0,0,0,0,0,0
*/

if exists (select * from sysobjects where id = object_id(N'[dbo].[DC_CSC_VEN_0040]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DC_CSC_VEN_0040]


go

create procedure DC_CSC_VEN_0040 (

  @@us_id    int,
  @@Fini      datetime,
  @@FFin      datetime,

@@cli_id         varchar(255),
@@suc_id         varchar(255), 
@@emp_id        varchar(255),
@@bConSaldos    smallint,
@@bSaldosCero   smallint,
@@doct_id       varchar(255) = '0'

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

declare @cli_id   int
declare @suc_id   int
declare @emp_id   int 
declare @doct_id  int

declare @ram_id_Cliente       int
declare @ram_id_Sucursal      int
declare @ram_id_Empresa       int 
declare @ram_id_DocumentoTipo  int

declare @clienteID int
declare @IsRaiz    tinyint

exec sp_ArbConvertId @@cli_id, @cli_id out, @ram_id_Cliente out
exec sp_ArbConvertId @@suc_id, @suc_id out, @ram_id_Sucursal out
exec sp_ArbConvertId @@emp_id, @emp_id out, @ram_id_Empresa out 
exec sp_ArbConvertId @@doct_id, @doct_id out, @ram_id_DocumentoTipo out 

exec sp_GetRptId @clienteID out

if @ram_id_Cliente <> 0 begin

--  exec sp_ArbGetGroups @ram_id_Cliente, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_Cliente, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_Cliente, @clienteID 
  end else 
    set @ram_id_Cliente = 0
end

if @ram_id_Sucursal <> 0 begin

--  exec sp_ArbGetGroups @ram_id_Sucursal, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_Sucursal, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_Sucursal, @clienteID 
  end else 
    set @ram_id_Sucursal = 0
end


if @ram_id_Empresa <> 0 begin

--  exec sp_ArbGetGroups @ram_id_Empresa, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_Empresa, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_Empresa, @clienteID 
  end else 
    set @ram_id_Empresa = 0
end

if @ram_id_DocumentoTipo <> 0 begin

--  exec sp_ArbGetGroups @ram_id_DocumentoTipo, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_DocumentoTipo, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_DocumentoTipo, @clienteID 
  end else 
    set @ram_id_DocumentoTipo = 0
end

/*- ///////////////////////////////////////////////////////////////////////

FIN PRIMERA PARTE DE ARBOLES

/////////////////////////////////////////////////////////////////////// */

create table #saldo (cli_id int, emp_id int, pendiente decimal(18,6))

if @@bConSaldos <> 0 begin

      insert into #saldo
      
      select 
      
        cli_id,
        emp_id,
        sum(case fv.doct_id
                when 7 then -fv_pendiente
                else         fv_pendiente
            end)
      
      from 
      
        FacturaVenta fv 
      where 
      
                fv_fecha < @@Fini 

            and fv.est_id <> 7
            and round(fv_pendiente,2) > 0
      
            and (
                  exists(select * from EmpresaUsuario where emp_id = fv.emp_id and us_id = @@us_id) or (@@us_id = 1)
                )
            and (
                  exists(select * from UsuarioEmpresa where cli_id = fv.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
                )

      /* -///////////////////////////////////////////////////////////////////////
      
      INICIO SEGUNDA PARTE DE ARBOLES
      
      /////////////////////////////////////////////////////////////////////// */
      
      and   (fv.cli_id  = @cli_id  or @cli_id=0)
      and   (fv.suc_id  = @suc_id  or @suc_id=0)
      and   (fv.emp_id  = @emp_id  or @emp_id=0) 
      and   (fv.doct_id = @doct_id or @doct_id=0) 
      
      -- Arboles
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
                 (@ram_id_Cliente = 0)
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
                 (@ram_id_Sucursal = 0)
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
                 (@ram_id_Empresa = 0)
             )
      
      and   (
                (exists(select rptarb_hojaid 
                        from rptArbolRamaHoja 
                        where
                             rptarb_cliente = @clienteID
                        and  tbl_id = 4003 
                        and  rptarb_hojaid = fv.doct_id
                       ) 
                 )
              or 
                 (@ram_id_DocumentoTipo = 0)
             )

      group by
            emp_id,
            cli_id
      
      insert into #saldo
      
      select 
      
        cli_id,
        emp_id,
        -sum(cobz_pendiente)
      
      from 
      
        Cobranza cobz   
      
      where 
      
                cobz_fecha < @@Fini 

            and cobz.est_id <> 7
            and round(cobz_pendiente,2) > 0
      
            and (
                  exists(select * from EmpresaUsuario where emp_id = cobz.emp_id and us_id = @@us_id) or (@@us_id = 1)
                )
            and (
                  exists(select * from UsuarioEmpresa where cli_id = cobz.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
                )

      /* -///////////////////////////////////////////////////////////////////////
      
      INICIO SEGUNDA PARTE DE ARBOLES
      
      /////////////////////////////////////////////////////////////////////// */
      
      and   (cobz.cli_id = @cli_id or @cli_id=0)
      and   (cobz.suc_id = @suc_id or @suc_id=0)
      and   (cobz.emp_id = @emp_id or @emp_id=0) 
      and   (cobz.doct_id = @doct_id or @doct_id=0) 
      
      -- Arboles
      and   (
                (exists(select rptarb_hojaid 
                        from rptArbolRamaHoja 
                        where
                             rptarb_cliente = @clienteID
                        and  tbl_id = 28 
                        and  rptarb_hojaid = cobz.cli_id
                       ) 
                 )
              or 
                 (@ram_id_Cliente = 0)
             )
      
      and   (
                (exists(select rptarb_hojaid 
                        from rptArbolRamaHoja 
                        where
                             rptarb_cliente = @clienteID
                        and  tbl_id = 1007 
                        and  rptarb_hojaid = cobz.suc_id
                       ) 
                 )
              or 
                 (@ram_id_Sucursal = 0)
             )
      
      and   (
                (exists(select rptarb_hojaid 
                        from rptArbolRamaHoja 
                        where
                             rptarb_cliente = @clienteID
                        and  tbl_id = 1018 
                        and  rptarb_hojaid = cobz.emp_id
                       ) 
                 )
              or 
                 (@ram_id_Empresa = 0)
             )
      
      and   (
                (exists(select rptarb_hojaid 
                        from rptArbolRamaHoja 
                        where
                             rptarb_cliente = @clienteID
                        and  tbl_id = 4003 
                        and  rptarb_hojaid = cobz.doct_id
                       ) 
                 )
              or 
                 (@ram_id_DocumentoTipo = 0)
             )

      group by
            emp_id,
            cli_id
      
end

/*-///////////////////////////////////////////////////////////////////////

  SELECT DE RETORNO

/////////////////////////////////////////////////////////////////////// */

/*-///////////////////////////////////////////////////////////////////////

  SALDO

/////////////////////////////////////////////////////////////////////// */

    select 
    
      0                          as cobz_id,
      0                         as fv_id,
      cli_codigo                as Codigo,
      cli_nombre                as Cliente,
      @@Fini                    as [Cobranza/NC Fecha],
      'Saldo inicial'           as [Cobranza/NC],
      emp_nombre                as [Empresa], 
      ''                        as [Cobranza/NC Comprobante],
      null                       as [Cobranza/NC Numero],
      0                          as [Cobranza/NC Total],
      0                          as [Cobranza/NC Pendiente],
      ''                        as [Cobranza/NC Legajo],
    
      null                      as [Factura Fecha],
      ''                        as [Documento de Venta],
      ''                        as [Factura Comprobante],
      0                         as [Factura Numero],
      ''                        as [Moneda],
      0                         as [Aplicacion],
      0                         as [Factura Total],
      sum(pendiente)             as [Factura Pendiente],
      ''                        as [Factura Legajo],
    
      0                         as Orden
    
    from #saldo s         inner join Cliente cli                     on s.cli_id   = cli.cli_id
                          inner join Empresa emp                    on s.emp_id   = emp.emp_id 
    
    group by
    
    emp_nombre,
    cli_nombre,
    cli_codigo

    having (sum(pendiente) <> 0 or @@bSaldosCero <> 0)
    
union all

/*-///////////////////////////////////////////////////////////////////////

  COBRANZAS

/////////////////////////////////////////////////////////////////////// */

    select 
    
      cobz.cobz_id              as cobz_id,
      fv.fv_id                  as fv_id,
      cli_codigo                as Codigo,
      cli_nombre                as Cliente,
      cobz_fecha                as [Cobranza/NC Fecha],
      doccobz.doc_nombre        as [Cobranza/NC],
      emp_nombre                as [Empresa], 
      cobz_nrodoc               as [Cobranza/NC Comprobante],
      cobz_numero               as [Cobranza/NC Numero],
      cobz_total                as [Cobranza/NC Total],
      cobz_pendiente            as [Cobranza/NC Pendiente],
      lgjcobz.lgj_codigo        as [Cobranza/NC Legajo],
      fv_fecha                  as [Factura Fecha],
      docfv.doc_nombre          as [Documento de Venta],
      fv_nrodoc                 as [Factura Comprobante],
      fv_numero                 as [Factura Numero],
      mon_nombre                as [Moneda],
      fvcobz_importe            as [Aplicacion],
      fv_total                  as [Factura Total],
      0                         as [Factura Pendiente],
      lgjfv.lgj_codigo          as [Factura Legajo],
    
      0                         as Orden
      
    
    from
    
      Cobranza cobz        inner join Cliente cli                     on cobz.cli_id        = cli.cli_id
                          inner join Sucursal                       on cobz.suc_id       = Sucursal.suc_id
                          inner join Documento doccobz              on cobz.doc_id       = doccobz.doc_id
                          inner join Empresa emp                    on doccobz.emp_id    = emp.emp_id 
                          left  join Legajo lgjcobz                 on cobz.lgj_id       = lgjcobz.lgj_id
                          left  join FacturaVentaCobranza fvcobz    on cobz.cobz_id      = fvcobz.cobz_id
                          left  join FacturaVenta fv                on fvcobz.fv_id      = fv.fv_id
                          left  join Documento docfv                on fv.doc_id         = docfv.doc_id
                          left  join Moneda m                       on fv.mon_id         = m.mon_id
                          left  join Legajo lgjfv                   on fv.lgj_id         = lgjfv.lgj_id
    where 
    
              cobz_fecha >= @@Fini
          and  cobz_fecha <= @@Ffin 
    
          and cobz.est_id <> 7
    
          and (
                exists(select * from EmpresaUsuario where emp_id = doccobz.emp_id and us_id = @@us_id) or (@@us_id = 1)
              )
          and (
                exists(select * from UsuarioEmpresa where cli_id = cli.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
              )

    /* -///////////////////////////////////////////////////////////////////////
    
    INICIO SEGUNDA PARTE DE ARBOLES
    
    /////////////////////////////////////////////////////////////////////// */
    
    and   (cli.cli_id       = @cli_id   or @cli_id=0)
    and   (Sucursal.suc_id   = @suc_id   or @suc_id=0)
    and   (emp.emp_id       = @emp_id   or @emp_id=0) 
    and   (cobz.doct_id     = @doct_id   or @doct_id=0) 
    
    -- Arboles
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 28 
                      and  rptarb_hojaid = cobz.cli_id
                     ) 
               )
            or 
               (@ram_id_Cliente = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1007 
                      and  rptarb_hojaid = cobz.suc_id
                     ) 
               )
            or 
               (@ram_id_Sucursal = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1018 
                      and  rptarb_hojaid = doccobz.emp_id
                     ) 
               )
            or 
               (@ram_id_Empresa = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 4003 
                      and  rptarb_hojaid = cobz.doct_id
                     ) 
               )
            or 
               (@ram_id_DocumentoTipo = 0)
           )

union all

/*-///////////////////////////////////////////////////////////////////////

  NOTAS DE CREDITO

/////////////////////////////////////////////////////////////////////// */

    select 
    
      nc.fv_id                   as cobz_id,
      fv.fv_id                  as fv_id,
      cli_codigo                as Codigo,
      cli_nombre                as Cliente,
      nc.fv_fecha                as [Cobranza/NC Fecha],
      docnc.doc_nombre          as [Cobranza/NC],
      emp_nombre                as [Empresa], 
      nc.fv_nrodoc              as [Cobranza/NC Comprobante],
      nc.fv_numero              as [Cobranza/NC Numero],
      nc.fv_total               as [Cobranza/NC Total],
      nc.fv_pendiente           as [Cobranza/NC Pendiente],
      lgjnc.lgj_codigo          as [Cobranza/NC Legajo],
      fv.fv_fecha               as [Factura Fecha],
      docfv.doc_nombre          as [Documento de Venta],
      fv.fv_nrodoc              as [Factura Comprobante],
      fv.fv_numero              as [Factura Numero],
      mon_nombre                as [Moneda],
      fvnc_importe              as [Aplicacion],
      fv.fv_total               as [Factura Total],
      0                         as [Factura Pendiente],
      lgjfv.lgj_codigo          as [Factura Legajo],
    
      0                         as Orden
      
    
    from
    
      FacturaVenta nc     inner join Cliente cli                     on nc.cli_id             = cli.cli_id
                          inner join Sucursal                       on nc.suc_id            = Sucursal.suc_id
                          inner join Documento docnc                on nc.doc_id            = docnc.doc_id
                          inner join Empresa emp                    on docnc.emp_id         = emp.emp_id 
                          left  join Legajo lgjnc                   on nc.lgj_id            = lgjnc.lgj_id
                          left  join FacturaVentaNotaCredito fvnc   on nc.fv_id             = fvnc.fv_id_notacredito
                          left  join FacturaVenta fv         on fvnc.fv_id_factura   = fv.fv_id
                          left  join Documento docfv                on fv.doc_id            = docfv.doc_id
                          left  join Moneda m                       on fv.mon_id            = m.mon_id
                          left  join Legajo lgjfv                   on fv.lgj_id            = lgjfv.lgj_id
    where 
    
              nc.fv_fecha >= @@Fini
          and  nc.fv_fecha <= @@Ffin 
          and nc.est_id <> 7
          and docnc.doct_id = 7 /* 7  Nota de Credito Venta */
    
          and (
                exists(select * from EmpresaUsuario where emp_id = docnc.emp_id and us_id = @@us_id) or (@@us_id = 1)
              )
           and (
                exists(select * from UsuarioEmpresa where cli_id = cli.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
              )

    /* -///////////////////////////////////////////////////////////////////////
    
    INICIO SEGUNDA PARTE DE ARBOLES
    
    /////////////////////////////////////////////////////////////////////// */
    
    and   (cli.cli_id       = @cli_id   or @cli_id=0)
    and   (Sucursal.suc_id   = @suc_id   or @suc_id=0)
    and   (emp.emp_id       = @emp_id   or @emp_id=0) 
    and   (nc.doct_id       = @doct_id   or @doct_id=0) 
    
    -- Arboles
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 28 
                      and  rptarb_hojaid = nc.cli_id
                     ) 
               )
            or 
               (@ram_id_Cliente = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1007 
                      and  rptarb_hojaid = nc.suc_id
                     ) 
               )
            or 
               (@ram_id_Sucursal = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1018 
                      and  rptarb_hojaid = docnc.emp_id
                     ) 
               )
            or 
               (@ram_id_Empresa = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 4003 
                      and  rptarb_hojaid = nc.doct_id
                     ) 
               )
            or 
               (@ram_id_DocumentoTipo = 0)
           )

union all

/*-///////////////////////////////////////////////////////////////////////

  FACTURAS DE VENTA Y NOTAS DE DEBITO

/////////////////////////////////////////////////////////////////////// */

    select 
    
      0                          as cobz_id,
      fv.fv_id                  as fv_id,
      cli_codigo                as Codigo,
      cli_nombre                as Cliente,
      null                      as [Cobranza/NC Fecha],
      ''                        as [Cobranza/NC],
      emp_nombre                as [Empresa], 
      ''                        as [Cobranza/NC Comprobante],
      null                       as [Cobranza/NC Numero],
      0                          as [Cobranza/NC Total],
      0                          as [Cobranza/NC Pendiente],
      ''                        as [Cobranza/NC Legajo],
      fv_fecha                  as [Factura Fecha],
      docfv.doc_nombre          as [Documento de Venta],
      fv_nrodoc                 as [Factura Comprobante],
      fv_numero                 as [Factura Numero],
      mon_nombre                as [Moneda],
      fv_total - fv_pendiente    as [Aplicacion],
      fv_total                  as [Factura Total],
      fv_pendiente              as [Factura Pendiente],
      lgjfv.lgj_codigo          as [Factura Legajo],
    
      1                         as Orden
    
    from
    
      FacturaVenta fv         inner join Cliente cli                     on fv.cli_id       = cli.cli_id
                              inner join Sucursal                       on fv.suc_id      = Sucursal.suc_id
                              inner join Documento docfv                on fv.doc_id      = docfv.doc_id
                              inner join Empresa emp                    on docfv.emp_id   = emp.emp_id 
                              inner join Moneda m                       on fv.mon_id      = m.mon_id
                              left  join Legajo lgjfv                   on fv.lgj_id      = lgjfv.lgj_id
    where 
    
              fv_fecha >= @@Fini
          and  fv_fecha <= @@Ffin 
    
          and fv.est_id <> 7
          and round(fv_pendiente,2) > 0
          and docfv.doct_id <> 7 /* 7  Nota de Credito Venta */
    
          and (
                exists(select * from EmpresaUsuario where emp_id = docfv.emp_id and us_id = @@us_id) or (@@us_id = 1)
              )
          and (
                exists(select * from UsuarioEmpresa where cli_id = cli.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
              )

    /* -///////////////////////////////////////////////////////////////////////
    
    INICIO SEGUNDA PARTE DE ARBOLES
    
    /////////////////////////////////////////////////////////////////////// */
    
    and   (cli.cli_id       = @cli_id   or @cli_id=0)
    and   (Sucursal.suc_id   = @suc_id   or @suc_id=0)
    and   (emp.emp_id       = @emp_id   or @emp_id=0) 
    and   (fv.doct_id       = @doct_id   or @doct_id=0) 
    
    -- Arboles
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
               (@ram_id_Cliente = 0)
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
               (@ram_id_Sucursal = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1018 
                      and  rptarb_hojaid = docfv.emp_id
                     ) 
               )
            or 
               (@ram_id_Empresa = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 4003 
                      and  rptarb_hojaid = fv.doct_id
                     ) 
               )
            or 
               (@ram_id_DocumentoTipo = 0)
           )

union all

    /*-///////////////////////////////////////////////////////////////////////
    
      REMITOS DE VENTA
    
    /////////////////////////////////////////////////////////////////////// */
    
    select 
    
      0                          as cobz_id,
      rv.rv_id                  as rv_id,
      cli_codigo                as Codigo,
      cli_nombre                as Cliente,
      null                      as [Cobranza/NC Fecha],
      ''                        as [Cobranza/NC],
      emp_nombre                as [Empresa], 
      ''                        as [Cobranza/NC Comprobante],
      null                       as [Cobranza/NC Numero],
      0                          as [Cobranza/NC Total],
      0                          as [Cobranza/NC Pendiente],
      ''                        as [Cobranza/NC Legajo],
    
      rv_fecha                  as [Factura Fecha],
      docrv.doc_nombre          as [Documento de Venta],
      rv_nrodoc                 as [Factura Comprobante],
      rv_numero                 as [Factura Numero],
      mon_nombre                as [Moneda],
      rv_total - rv_pendiente    as [Aplicacion],
      rv_total                  as [Factura Total],
      rv_pendiente              as [Factura Pendiente],
      lgjrv.lgj_codigo as [Factura Legajo],
    
      2                         as Orden
    
    from
    
      RemitoVenta rv           inner join Cliente cli                     on rv.cli_id       = cli.cli_id
                              inner join Sucursal                       on rv.suc_id      = Sucursal.suc_id
                              inner join Documento docrv                on rv.doc_id      = docrv.doc_id
                              inner join Empresa emp                    on docrv.emp_id   = emp.emp_id 
                              inner join Moneda m                       on docrv.mon_id   = m.mon_id
                              left  join Legajo lgjrv                   on rv.lgj_id      = lgjrv.lgj_id
    where 
    
              rv_fecha >= @@Fini
          and  rv_fecha <= @@Ffin 
    
          and rv.est_id <> 7
          and round(rv_pendiente,2) > 0
          and docrv.doct_id <> 24 /* 24  Devolucion Remito Venta */
    
          and (
                exists(select * from EmpresaUsuario where emp_id = docrv.emp_id and us_id = @@us_id) or (@@us_id = 1)
              )
          and (
                exists(select * from UsuarioEmpresa where cli_id = cli.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
              )

    /* -///////////////////////////////////////////////////////////////////////
    
    INICIO SEGUNDA PARTE DE ARBOLES
    
    /////////////////////////////////////////////////////////////////////// */
    
    and   (cli.cli_id       = @cli_id   or @cli_id=0)
    and   (Sucursal.suc_id   = @suc_id   or @suc_id=0)
    and   (emp.emp_id       = @emp_id   or @emp_id=0) 
    and   (rv.doct_id       = @doct_id   or @doct_id=0) 
    
    -- Arboles
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 28 
                      and  rptarb_hojaid = rv.cli_id
                     ) 
               )
            or 
               (@ram_id_Cliente = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1007 
                      and  rptarb_hojaid = rv.suc_id
                     ) 
               )
            or 
               (@ram_id_Sucursal = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1018 
                      and  rptarb_hojaid = docrv.emp_id
                     ) 
               )
            or 
               (@ram_id_Empresa = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 4003 
                      and  rptarb_hojaid = rv.doct_id
                     ) 
               )
            or 
               (@ram_id_DocumentoTipo = 0)
           )

union all

/*-///////////////////////////////////////////////////////////////////////

  PEDIDOS DE VENTA

/////////////////////////////////////////////////////////////////////// */

    select 
    
      0                          as cobz_id,
      pv.pv_id                  as pv_id,
      cli_codigo                as Codigo,
      cli_nombre                as Cliente,
      null                      as [Cobranza/NC Fecha],
      ''                        as [Cobranza/NC],
      emp_nombre                as [Empresa], 
      ''                        as [Cobranza/NC Comprobante],
      null                       as [Cobranza/NC Numero],
      0                          as [Cobranza/NC Total],
      0                          as [Cobranza/NC Pendiente],
      ''                        as [Cobranza/NC Legajo],
    
      pv_fecha                  as [Factura Fecha],
      docpv.doc_nombre          as [Documento de Venta],
      pv_nrodoc                 as [Factura Comprobante],
      pv_numero                 as [Factura Numero],
      mon_nombre                as [Moneda],
      pv_total - pv_pendiente    as [Aplicacion],
      pv_total                  as [Factura Total],
      pv_pendiente              as [Factura Pendiente],
      lgjpv.lgj_codigo          as [Factura Legajo],
    
      3                         as Orden
    
    from
    
      PedidoVenta pv           inner join Cliente cli                     on pv.cli_id       = cli.cli_id
                              inner join Sucursal                       on pv.suc_id      = Sucursal.suc_id
                              inner join Documento docpv                on pv.doc_id      = docpv.doc_id
                              inner join Empresa emp                    on docpv.emp_id   = emp.emp_id 
                              inner join Moneda m                       on docpv.mon_id   = m.mon_id
                              left  join Legajo lgjpv                   on pv.lgj_id      = lgjpv.lgj_id
    where 
    
              pv_fecha >= @@Fini
          and  pv_fecha <= @@Ffin 
    
          and pv.est_id <> 7
          and round(pv_pendiente,2) > 0
          and docpv.doct_id <> 22 /* 24  Devolucion Pedido Venta  select * from documentotipo */
    
          and (
                exists(select * from EmpresaUsuario where emp_id = docpv.emp_id and us_id = @@us_id) or (@@us_id = 1)
              )
          and (
                exists(select * from UsuarioEmpresa where cli_id = cli.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
              )

    /* -///////////////////////////////////////////////////////////////////////
    
    INICIO SEGUNDA PARTE DE ARBOLES
    
    /////////////////////////////////////////////////////////////////////// */
    
    and   (cli.cli_id       = @cli_id   or @cli_id=0)
    and   (Sucursal.suc_id   = @suc_id   or @suc_id=0)
    and   (emp.emp_id       = @emp_id   or @emp_id=0) 
    and   (pv.doct_id       = @doct_id   or @doct_id=0) 
    
    -- Arboles
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 28 
                      and  rptarb_hojaid = pv.cli_id
                     ) 
               )
            or 
               (@ram_id_Cliente = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1007 
                      and  rptarb_hojaid = pv.suc_id
                     ) 
               )
            or 
               (@ram_id_Sucursal = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1018 
                      and  rptarb_hojaid = docpv.emp_id
                     ) 
               )
            or 
               (@ram_id_Empresa = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 4003 
                      and  rptarb_hojaid = pv.doct_id
                     ) 
               )
            or 
               (@ram_id_DocumentoTipo = 0)
           )

--///////////////////////////////////////////////////////////////

order by

  Cliente, Orden, [Cobranza/NC Fecha], [Factura Fecha]

end

GO