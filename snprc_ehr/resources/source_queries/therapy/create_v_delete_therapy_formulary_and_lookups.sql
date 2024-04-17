CREATE VIEW labkey_etl.v_delete_therapy_formulary_and_lookups AS

-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/4/2024
-- Description: selects deleted rows for the drug_list and all related lookup tables
-- Changes:
--
-- ==========================================================================================

SELECT
    adl.object_id,
    adl.audit_date_tm
FROM audit.audit_drug_list AS adl
WHERE adl.audit_action = 'D' AND adl.object_id IS NOT NULL

UNION

SELECT
    avtu.object_id,
    avtu.audit_date_tm
FROM audit.audit_valid_therapy_units AS avtu
WHERE avtu.audit_action = 'D' AND avtu.object_id IS NOT NULL

UNION

SELECT
    avtf.object_id,
    avtf.audit_date_tm
FROM audit.audit_valid_therapy_frequencies AS avtf
WHERE avtf.audit_action = 'D' AND avtf.object_id IS NOT NULL

UNION

SELECT
    avtr.object_id,
    avtr.audit_date_tm
FROM audit.audit_valid_therapy_resolutions AS avtr
WHERE avtr.audit_action = 'D' AND avtr.object_id IS NOT NULL

UNION

SELECT
    avtr.object_id,
    avtr.audit_date_tm
FROM audit.audit_valid_therapy_routes AS avtr
WHERE avtr.audit_action = 'D' AND avtr.object_id IS NOT NULL

GO


GRANT SELECT ON Labkey_etl.v_delete_therapy_formulary_and_lookups TO z_labkey

GRANT SELECT ON audit.audit_drug_list TO z_labkey
GRANT SELECT ON audit.audit_valid_therapy_units TO z_labkey
GRANT SELECT ON audit.audit_valid_therapy_frequencies TO z_labkey
GRANT SELECT ON audit.audit_valid_therapy_resolutions TO z_labkey
GRANT SELECT ON audit.audit_valid_therapy_routes TO z_labkey
GO