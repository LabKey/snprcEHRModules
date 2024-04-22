CREATE VIEW labkey_etl.v_therapy_resolutions AS
    -- ====================================================================================================================
-- Object: v_therapy_routes
-- Author:		Terry Hawkins
-- Create date: 4/3/2024
-- Changes:
--
-- ==========================================================================================

SELECT
    vtr.tid                           AS RowId,
    vtr.resolution                    AS resolution,
    CASE WHEN vtr.status = 'A' THEN 1 ELSE 0 END  AS isActive,
    vtr.entry_date_tm                 AS modified,
    dbo.f_map_username(vtr.user_name) AS modifiedby,
    tc.created                        AS created,
    tc.createdby                      AS createdby,
    vtr.object_id                     AS objectid,
    vtr.timestamp
FROM dbo.valid_therapy_resolutions AS vtr
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = vtr.object_id

    GO

GRANT SELECT ON labkey_etl.v_therapy_resolutions TO z_labkey

    GO