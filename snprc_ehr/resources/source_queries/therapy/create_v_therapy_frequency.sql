CREATE VIEW labkey_etl.v_therapy_frequency AS
-- ====================================================================================================================
-- Object: v_therapy_frequency
-- Author:		Terry Hawkins
-- Create date: 4/3/2024
-- Changes:
--
-- ==========================================================================================

SELECT
    vtf.tid                           AS RowId,
    vtf.frequency                     AS frequency,
    vtf.description                   AS description,
    vtf.isActive                      AS isActive,
    vtf.entry_date_tm                 AS modified,
    dbo.f_map_username(vtf.user_name) AS modifiedby,
    tc.created                       AS created,
    tc.createdby                     AS createdby,
    vtf.object_id                     AS objectid,
    vtf.timestamp
FROM dbo.valid_therapy_frequencies AS vtf
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = vtf.object_id

    GO

GRANT SELECT ON labkey_etl.v_therapy_frequency TO z_labkey

    GO