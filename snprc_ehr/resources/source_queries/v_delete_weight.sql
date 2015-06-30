USE [animal]
GO

/****** Object:  View [labkey_etl].[V_DELETE_WEIGHT]    Script Date: 6/29/2015 10:10:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*==============================================================*/
/* View: V_DELETE_WEIGHT                                               */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_WEIGHT] AS
-- ====================================================================================================================
-- Author:	Terry Hawkins
-- Create date: 6/30/2015
--
-- ==========================================================================================

SELECT cp.OBJECT_ID,
       cp.AUDIT_DATE_TM
	
FROM audit.audit_coded_procs cp 
INNER JOIN dbo.ANIMAL_EVENTS ae ON cp.animal_event_id = ae.animal_event_id
INNER JOIN audit.audit_CODED_PROC_ATTRIBS cpa ON cp.PROC_ID = cpa.PROC_ID
INNER JOIN dbo.budget_items bi ON bi.BUDGET_ITEM_ID = cp.BUDGET_ITEM_ID
INNER JOIN dbo.SUPER_PKGS sp ON sp.SUPER_PKG_ID = bi.SUPER_PKG_ID
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ae.animal_id

WHERE sp.PKG_ID IN (6, 152) AND cpa.ATTRIB_KEY = 'weight'

UNION


SELECT cp.OBJECT_ID,
       cp.AUDIT_DATE_TM
	
FROM audit.audit_coded_procs cp 
INNER JOIN audit.audit_ANIMAL_EVENTS ae ON cp.animal_event_id = ae.animal_event_id
INNER JOIN audit.audit_CODED_PROC_ATTRIBS cpa ON cp.PROC_ID = cpa.PROC_ID
INNER JOIN dbo.budget_items bi ON bi.BUDGET_ITEM_ID = cp.BUDGET_ITEM_ID
INNER JOIN dbo.SUPER_PKGS sp ON sp.SUPER_PKG_ID = bi.SUPER_PKG_ID
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ae.animal_id

WHERE sp.PKG_ID IN (6, 152) AND cpa.ATTRIB_KEY = 'weight'
GO

GRANT SELECT ON labkey_etl.V_DELETE_WEIGHT TO z_labkey
go

