ALTER VIEW labkey_etl.v_exp_vaccines AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2020
-- Description:	Selects the vaccines data for LK ETL
-- Note:
--
-- Changes:
-- 4/9/2020 changed camel casing to title casing. tjh
-- ==========================================================================================
SELECT v.id AS Id,
       v.start_date AS Date,
       CASE WHEN v.start_date_estimator = 'Y' THEN 'true'
            WHEN v.start_date_estimator = 'N' THEN 'false'
            ELSE NULL END  AS IsDateEstimate,
       va.description AS Agent,
       vi.description AS ImmunizationType,
       CASE WHEN v.protection = 'U' THEN 'Unknown'
            WHEN v.protection = 'N' THEN 'No'
            WHEN v.protection = 'Y' THEN 'Yes'
            ELSE 'N/A' END AS Protection,
       v.num_doses AS NumDoses,
       v.object_id AS ObjectId,
       v.entry_date_tm AS Modified,
       dbo.f_map_username(v.user_name) AS ModifiedBy,
       COALESCE(tc.created, v.entry_date_tm) AS Created ,
       COALESCE(tc.createdby, dbo.f_map_username(v.user_name)) AS CreatedBy,
       v.timestamp AS Timestamp
FROM exposure.dbo.vaccines AS v
         INNER JOIN exposure.dbo.valid_vaccine_agents AS va ON v.agent_id = va.agent_id
         INNER JOIN exposure.dbo.valid_immunization_types AS vi ON v.immunization_type_id = vi.immunization_type_id
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = v.object_id
         INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = v.id


    GO

GRANT SELECT ON labkey_etl.v_exp_vaccines TO z_labkey
    GO