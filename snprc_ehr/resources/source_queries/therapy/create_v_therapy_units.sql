CREATE VIEW labkey_etl.v_therapy_units AS
    -- ====================================================================================================================
-- Object: v_therapy_units
-- Author:		Terry Hawkins
-- Create date: 4/3/2024
-- Changes:
--
-- ==========================================================================================

SELECT
    vtu.tid                           AS RowId,
    vtu.units                         AS units,
    vtu.description                   AS description,
    vtu.isActive                      AS isActive,
    vtu.entry_date_tm                 AS modified,
    dbo.f_map_username(vtu.user_name) AS modifiedby,
    tc.created                       AS created,
    tc.createdby                     AS createdby,
    vtu.object_id                     AS objectid,
    vtu.timestamp
FROM dbo.valid_therapy_units AS vtu
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = vtu.object_id

    GO

GRANT SELECT ON labkey_etl.v_therapy_units TO z_labkey

    GO