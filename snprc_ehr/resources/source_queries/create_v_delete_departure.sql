USE [animal]
GO

/****** Object:  View [labkey_etl].[V_DELETE_DEPARTURE]    Script Date: 6/26/2015 11:20:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_DELETE_DEPARTURE                                            */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_DEPARTURE] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/26/2015
-- Description:	Selects the ETL records for LabKey study.departure dataset for deletes
-- Changes:
--
--
-- ==========================================================================================

SELECT ad.object_id,
	   ad.audit_date_tm
FROM audit.audit_acq_disp AS ad
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ad.id
WHERE ad.audit_action = 'D' AND ad.object_id IS NOT NULL

GO

GRANT SELECT ON Labkey_etl.v_delete_departure TO z_labkey 
GRANT SELECT ON audit.audit_acq_disp TO z_labkey
GO

