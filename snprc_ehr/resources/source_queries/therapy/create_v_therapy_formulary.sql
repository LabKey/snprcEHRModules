CREATE VIEW labkey_etl.v_therapy_formulary AS
    -- ====================================================================================================================
-- Object: v_therapy_formulary
-- Author:		Terry Hawkins
-- Create date: 4/4/2024
-- Changes:
--
-- ==========================================================================================

SELECT
    dl.tid                           AS RowId,
    dl.drug                          AS drug,
    dl.dose                          AS dose,
    vtr.tid                          AS route,
    vtf.tid                          AS frequency,
    dl.duration                      AS duration,
    vtu.tid                          AS units,
    dl.isActive                      AS isActive,
    dl.dateDisabled                  AS dateDisabled,
    dl.entry_date_tm                 AS modified,
    dbo.f_map_username(dl.user_name) AS modifiedby,
    tc.created                       AS created,
    tc.createdby                     AS createdby,
    dl.object_id                     AS objectid,
    dl.timestamp
FROM dbo.drug_list AS dl
INNER JOIN dbo.valid_therapy_frequencies AS vtf ON dl.frequency = vtf.frequency
INNER JOIN dbo.valid_therapy_routes AS vtr ON dl.route = vtr.route
INNER JOIN dbo.valid_therapy_units AS vtu ON dl.units = vtu.units
LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = dl.object_id

GO

GRANT SELECT ON dbo.drug_list TO z_labkey
GRANT SELECT ON dbo.valid_therapy_frequencies TO z_labkey
GRANT SELECT ON dbo.valid_therapy_routes TO z_labkey
GRANT SELECT ON dbo.valid_therapy_units TO z_labkey
GRANT SELECT ON labkey_etl.v_therapy_formulary TO z_labkey

GO