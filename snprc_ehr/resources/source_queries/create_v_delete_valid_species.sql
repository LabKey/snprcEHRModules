CREATE VIEW [labkey_etl].[V_DELETE_valid_species] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 11/23/2015
-- Description:	Selects the ETL records for LabKey snprc_ehr.valid_species dataset which need to be deleted
-- Changes:
--
--
-- ==========================================================================================

SELECT
	avs.object_id,
	avs.audit_date_tm
FROM audit.audit_valid_species AS avs
WHERE avs.audit_action = 'D' AND avs.object_id IS NOT NULL

GO

GRANT SELECT ON Labkey_etl.v_delete_valid_species TO z_labkey
GRANT SELECT ON audit.audit_valid_species TO z_labkey

GO
