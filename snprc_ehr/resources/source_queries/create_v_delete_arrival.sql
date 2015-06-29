USE [animal]
GO

/****** Object:  View [labkey_etl].[V_DELETE_ARRIVAL]    Script Date: 6/25/2015 10:29:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_DELETE_ARRIVAL                                         */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_ARRIVAL] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2015
-- Description:	Selects the ETL records for LabKey study.arrival dataset which need to be deleted
-- Changes:
--
--
-- ==========================================================================================

SELECT 
	ad.object_id,
	ad.audit_date_tm
FROM audit.audit_acq_disp AS ad
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ad.id
WHERE ad.audit_action = 'D' AND ad.object_id IS NOT NULL

GO

GRANT SELECT ON Labkey_etl.v_delete_arrival TO z_labkey 
GRANT SELECT ON audit.audit_acq_disp TO z_labkey

GO

