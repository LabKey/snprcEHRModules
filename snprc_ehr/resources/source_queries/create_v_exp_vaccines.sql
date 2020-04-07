ALTER VIEW labkey_etl.v_exp_vaccines AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2020
-- Description:	Selects the vaccines data for LK ETL
-- Note:
--
-- Changes:
--
-- ==========================================================================================
SELECT v.id AS id,
       v.start_date AS date,
       CASE WHEN v.start_date_estimator = 'Y' THEN 'true'
            WHEN v.start_date_estimator = 'N' THEN 'false'
            ELSE NULL END  AS isDateEstimate,
       va.description AS agent,
       vi.description AS immunizationType,
       CASE WHEN v.protection = 'U' THEN 'Unknown'
            WHEN v.protection = 'N' THEN 'No'
            WHEN v.protection = 'Y' THEN 'Yes'
            ELSE 'N/A' END AS protection,
       v.num_doses AS numDoses,
       v.object_id AS objectid,
       v.entry_date_tm AS modified,
       dbo.f_map_username(v.user_name) AS modifiedby,
       COALESCE(tc.created, v.entry_date_tm) AS created ,
       COALESCE(tc.createdby, dbo.f_map_username(v.user_name)) AS createdby,
       v.timestamp AS timestamp
FROM exposure.dbo.vaccines AS v
         INNER JOIN exposure.dbo.valid_vaccine_agents AS va ON v.agent_id = va.agent_id
         INNER JOIN exposure.dbo.valid_immunization_types AS vi ON v.immunization_type_id = vi.immunization_type_id
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = v.object_id
         INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = v.id


    GO

GRANT SELECT ON labkey_etl.v_exp_vaccines TO z_labkey
    GO