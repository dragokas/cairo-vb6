SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_ArticuloGetByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_ArticuloGetByID]
GO


-- sp_web_ArticuloGetByID 2

create Procedure sp_web_ArticuloGetByID
(
  @@wart_id       int
)
as
begin

  -- Devuelve todos los datos del articulo, inclusive el nombre del estado, tipo y autor

  Select 
          a.wart_id, 
          t.wartt_id, 
          e.warte_id, 
          u.us_id,
          wart_titulo            as [Titulo], 
          wart_copete            as [Copete], 
          wart_Texto            as [Texto], 
          wart_origen            as [Origen], 
          wart_origenurl        as [Origen Url], 
          wart_fecha            as [Fecha], 
          wart_fechaVto          as [FechaVto], 
          wart_imagen            as [Imagen], 
          us_nombre             as [Usuario], 
          warte_nombre          as [Estado], 
          wartt_nombre           as [Tipo]

  from 
        webArticulo a inner join Usuario u                 on a.us_id    = u.us_id
                       inner join webArticuloEstado e       on a.warte_id = e.warte_id
                       inner join webArticuloTipo t        on a.wartt_id = t.wartt_id

  where 
      wart_id = @@wart_id

end

go
set quoted_identifier off 
go
set ansi_nulls on 
go

