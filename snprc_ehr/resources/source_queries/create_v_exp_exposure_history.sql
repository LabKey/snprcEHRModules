ALTER VIEW labkey_etl.v_exp_exposure_history AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2020
-- Description:	Selects the exposure_history data for LK ETL
-- Note:
--
-- Changes:
--
-- ==========================================================================================

SELECT eh.id AS id,
       eh.doi AS date,
       CASE WHEN eh.doi_estimator = 'Y' THEN 'true'
            WHEN eh.doi_estimator = 'N' THEN 'false'
            ELSE NULL END  AS isDateEstimate,
       vc.description AS virusCategory,
       vv.description AS virusName,
       vei.description AS inoculum,
       eh.description AS description,
       ver.route AS route,
       eh.object_id AS objectid,
       eh.entry_date_tm AS modified,
       dbo.f_map_username(eh.user_name) AS modifiedby,
       COALESCE(tc.created, eh.entry_date_tm) AS created ,
       COALESCE(tc.createdby, dbo.f_map_username(eh.user_name)) AS createdby,
       eh.timestamp AS timestamp
FROM exposure.dbo.exposure_history AS eh
         LEFT JOIN exposure.dbo.valid_exposure_inoculums AS vei ON vei.inoculum_id = eh.inoculum_id
         LEFT JOIN exposure.dbo.valid_viruses AS vv ON vv.virus_id = eh.virus_id
         LEFT JOIN exposure.dbo.valid_exposure_routes AS ver ON ver.route_id = eh.route_id
         LEFT JOIN exposure.dbo.virus_categories AS vc ON vc.virus_category_id = vv.virus_category_id
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = eh.object_id
         INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = eh.id

    GO

GRANT SELECT ON labkey_etl.v_exp_exposure_history TO z_labkey
    GO