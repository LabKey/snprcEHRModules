CREATE VIEW [labkey_etl].[v_delete_valid_vaccines] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 07/19/2019
-- Description:	Selects the valid_vaccines for LabKey snprc_ehr.valid_vaccine dataset for deletions
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT avv.object_id,
       avv.audit_date_tm


FROM audit.audit_valid_vaccines AS avv

WHERE avv.audit_action = 'D'
  AND avv.object_id IS NOT NULL
    GO


GRANT SELECT on labkey_etl.v_delete_valid_vaccines to z_labkey
GRANT SELECT ON audit.audit_valid_vaccines TO z_labkey
    go