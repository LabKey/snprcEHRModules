USE [animal]
GO

/****** Object:  View [labkey_etl].[v_delete_weight]    Script Date: 8/4/2015 2:54:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/*==============================================================*/
/* View: V_DELETE_TB                                               */
/*==============================================================*/
ALTER VIEW [labkey_etl].[v_delete_tb] AS
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

WHERE sp.PKG_ID = 8 AND cpa.ATTRIB_KEY = 'tb_result'
  AND cp.AUDIT_ACTION = 'D' AND cp.OBJECT_ID IS NOT null

UNION

-- include rows that have had the animal event deleted
SELECT cp.OBJECT_ID,
       cp.AUDIT_DATE_TM
	
FROM audit.audit_coded_procs cp 
INNER JOIN audit.audit_ANIMAL_EVENTS ae ON cp.animal_event_id = ae.animal_event_id
INNER JOIN audit.audit_CODED_PROC_ATTRIBS cpa ON cp.PROC_ID = cpa.PROC_ID
INNER JOIN dbo.budget_items bi ON bi.BUDGET_ITEM_ID = cp.BUDGET_ITEM_ID
INNER JOIN dbo.SUPER_PKGS sp ON sp.SUPER_PKG_ID = bi.SUPER_PKG_ID
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ae.animal_id

WHERE sp.PKG_ID = 8 AND cpa.ATTRIB_KEY = 'tb_result'
  AND cp.AUDIT_ACTION = 'D' AND cp.OBJECT_ID IS NOT null


GO


GRANT SELECT ON labkey_etl.V_DELETE_TB TO z_labkey
GRANT SELECT ON audit.AUDIT_CODED_PROCS TO z_labkey
GRANT SELECT ON audit.AUDIT_CODED_PROC_ATTRIBS TO z_labkey
go