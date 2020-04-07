ALTER VIEW labkey_etl.v_exp_research_treatments AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2020
-- Description:	Selects the research_treatments data for LK ETL
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT rt.id AS id,
       rt.infusion_date as infusion_date,
       CASE WHEN rt.infusion_date_estimator = 'Y' THEN 'true'
            WHEN rt.infusion_date_estimator = 'N' THEN 'false'
            ELSE NULL END  AS isDateEstimate,
       vtc.description AS treatmentCategory,
       vtn.description AS treatmentName,
       rt.description AS description,
       rt.object_id AS objectid,
       rt.entry_date_tm AS modified,
       dbo.f_map_username(rt.user_name) AS modifiedby,
       COALESCE(tc.created, rt.entry_date_tm) AS created ,
       COALESCE(tc.createdby, dbo.f_map_username(rt.user_name)) AS createdby,
       rt.timestamp AS timestamp
FROM exposure.dbo.research_treatments AS rt
         LEFT OUTER JOIN exposure.dbo.valid_tr_categories as vtc on vtc.treatment_category_id = rt.treatment_category_id
         LEFT OUTER JOIN exposure.dbo.valid_tr_names as vtn on vtn.treatment_name_id = rt.treatment_name_id
         LEFT OUTER JOIN exposure.dbo.valid_institutions as vi on vi.institution_id = rt.responsible_institution_id
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = rt.object_id
         INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = rt.id

    GO

GRANT SELECT ON labkey_etl.v_exp_research_treatments TO z_labkey
    GO

