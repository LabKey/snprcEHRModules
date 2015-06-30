USE [animal]
GO

/****** Object:  View [labkey_etl].[v_delete_clinical_admissions]    Script Date: 6/29/2015 2:36:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [labkey_etl].[v_delete_clinical_admissions] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/26/2015
-- Description:	Selects the clinical admissions for LabKey study.clinical_observations dataset for deletions
-- Note: 
--		
-- Changes:
--
-- ==========================================================================================


SELECT ac.object_id,
	   ac.audit_date_tm



FROM audit.audit_clinic AS ac
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ac.id
WHERE ac.audit_action = 'D' AND ac.object_id IS NOT NULL



GO


GRANT SELECT on labkey_etl.v_delete_clinical_admissions to z_labkey
GRANT SELECT ON audit.audit_clinic TO z_labkey

go