USE [animal]
GO

/****** Object:  View [labkey_etl].[v_delete_clinical_admissions]    Script Date: 6/29/2015 2:36:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [labkey_etl].[v_delete_valid_vets] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 8/5/2016
-- Description:	Selects the valid_vets for LabKey snprc_ehr.valid_vets dataset for deletions
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT avv.object_id,
	   avv.audit_date_tm


FROM audit.audit_valid_vet AS avv

WHERE avv.audit_action = 'D' AND avv.object_id IS NOT NULL



GO


GRANT SELECT on labkey_etl.v_delete_valid_vets to z_labkey
GRANT SELECT ON audit.audit_valid_vet TO z_labkey

go