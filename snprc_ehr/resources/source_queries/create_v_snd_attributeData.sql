USE [animal]
GO

/****** Object:  View [labkey_etl].[v_snd_attributeData]    Script Date: 4/2/2018 7:17:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [labkey_etl].[v_snd_attributeData]
AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 2/23/2018
-- Description:	View provides the datasource for event data with attribute/values
-- Changes:
--
-- ==========================================================================================
SELECT TOP (99.999999999) PERCENT
  cp.ANIMAL_EVENT_ID               AS EventId,
  sp.PKG_ID                        AS PkgId,
  -- snd.EventData columns
  cp.PROC_ID                       AS EventDataId,
  sp.SUPER_PKG_ID                  AS SuperPkgId,
  pbi.SUPER_PKG_ID                 AS ParentSuperPkgId,

  -- exp.ObjectProperty columns
  cpa.ATTRIB_KEY AS [ KEY],

  CASE WHEN (LOWER(pa.DATA_TYPE) = 'numeric' OR
    LOWER(pa.DATA_TYPE) = 'decimal')
    THEN CAST (cpa.value AS FLOAT ) ELSE NULL END AS FloatValue,

  CASE WHEN LOWER(pa.DATA_TYPE) = 'string'
    THEN cpa.value ELSE NULL END AS StringValue,

  CASE WHEN (LOWER(pa.DATA_TYPE)) = 'string' THEN 's' ELSE 'f' END AS TypeTag,

cp.OBJECT_ID AS objectId,
( SELECT MAX(v) FROM ( VALUES (cp.timestamp), (cpa.timestamp)) AS VALUE (v)) AS TIMESTAMP


FROM dbo.CODED_PROCS AS cp
INNER JOIN dbo.ANIMAL_EVENTS AS ae ON cp.ANIMAL_EVENT_ID = ae.ANIMAL_EVENT_ID
INNER JOIN dbo.CODED_PROC_ATTRIBS AS cpa ON cpa.PROC_ID = cp.PROC_ID
INNER JOIN dbo.BUDGET_ITEMS AS bi ON cp.BUDGET_ITEM_ID = bi.BUDGET_ITEM_ID
INNER JOIN dbo.BUDGET_ITEMS AS pbi ON pbi.BUDGET_ITEM_ID = bi.PARENT_BUDGET_ITEM_ID
INNER JOIN dbo.SUPER_PKGS AS sp ON sp.SUPER_PKG_ID = bi.SUPER_PKG_ID
INNER JOIN dbo.PKGS AS p ON p.PKG_ID = sp.PKG_ID
INNER JOIN dbo.PKG_ATTRIBS AS pa ON pa.PKG_ID = p.PKG_ID AND pa.ATTRIB_KEY = cpa.ATTRIB_KEY


-- select primates only from the TxBiomed colony
INNER JOIN labkey_etl.V_DEMOGRAPHICS AS D ON D.id = ae.ANIMAL_ID
ORDER BY EventDataId

GO
