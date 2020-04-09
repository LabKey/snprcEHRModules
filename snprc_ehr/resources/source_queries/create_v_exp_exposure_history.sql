ALTER VIEW labkey_etl.v_exp_exposure_history AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2020
-- Description:	Selects the exposure_history data for LK ETL
-- Note:
--
-- Changes:
-- 4/9/2020 changed camel casing to title casing. tjh
-- ==========================================================================================

SELECT eh.id AS Id,
       eh.doi AS Date,
       CASE WHEN eh.doi_estimator = 'Y' THEN 'true'
            WHEN eh.doi_estimator = 'N' THEN 'false'
            ELSE NULL END  AS IsDateEstimate,
       vc.description AS VirusCategory,
       vv.description AS VirusName,
       vei.description AS Inoculum,
       eh.description AS Description,
       ver.route AS Route,
       eh.object_id AS ObjectId,
       eh.entry_date_tm AS Modified,
       dbo.f_map_username(eh.user_name) AS ModifiedBy,
       COALESCE(tc.created, eh.entry_date_tm) AS Created ,
       COALESCE(tc.createdby, dbo.f_map_username(eh.user_name)) AS CreatedBy,
       eh.timestamp AS Timestamp
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