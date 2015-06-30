USE [animal]
GO

/****** Object:  View [labkey_etl].[V_DELETE_DEATH]    Script Date: 6/26/2015 10:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_DELETE_DEATH                                         */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_DEATH] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/26/2015
-- Description:	Selects the ETL records for LabKey study.birth dataset which need to be deleted
-- Changes:
--
--
-- ==========================================================================================

SELECT am.object_id,
	am.audit_date_tm
FROM audit.audit_master AS am
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = am.id
WHERE am.audit_action = 'D' AND am.object_id IS NOT NULL

GO

GRANT SELECT ON Labkey_etl.V_DELETE_DEATH TO z_labkey 
GRANT SELECT ON audit.audit_acq_disp TO z_labkey

GO

