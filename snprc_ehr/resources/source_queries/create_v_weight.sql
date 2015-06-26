USE [animal]
GO

/****** Object:  View [labkey_etl].[V_WEIGHT]    Script Date: 11/12/2014 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_WEIGHT                                               */
/*==============================================================*/
ALTER view [labkey_etl].[V_WEIGHT] as
-- ====================================================================================================================
-- Object: v_weight2
-- Author:	Terry Hawkins
-- Create date: 1/2015
--
-- ==========================================================================================

SELECT ae.ANIMAL_ID AS id, 
	ae.EVENT_DATE_TM AS date,
	CAST(cpa.VALUE AS NUMERIC(7,4)) AS weight,
	CAST(cpa.OBJECT_ID AS VARCHAR(36)) as objectid,
	cpa.USER_NAME AS user_name,
	cpa.ENTRY_DATE_TM AS entry_date_tm,
	cpa.TIMESTAMP
	
FROM dbo.coded_procs cp 
INNER JOIN dbo.ANIMAL_EVENTS ae ON cp.animal_event_id = ae.animal_event_id
INNER JOIN dbo.CODED_PROC_ATTRIBS cpa ON cp.PROC_ID = cpa.PROC_ID
INNER JOIN dbo.budget_items bi ON bi.BUDGET_ITEM_ID = cp.BUDGET_ITEM_ID
INNER JOIN dbo.SUPER_PKGS sp ON sp.SUPER_PKG_ID = bi.SUPER_PKG_ID
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ae.animal_id

WHERE sp.PKG_ID in (6, 152) AND cpa.ATTRIB_KEY = 'weight'

GO

GRANT SELECT ON Labkey_etl.v_departure TO z_labkey
GO

