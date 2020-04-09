ALTER VIEW labkey_etl.v_exp_research_treatments AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2020
-- Description:	Selects the research_treatments data for LK ETL
-- Note:
--
-- Changes:
-- 4/9/2020 changed camel casing to title casing. tjh
-- ==========================================================================================


SELECT rt.id AS Id,
       rt.infusion_date as Date,
       CASE WHEN rt.infusion_date_estimator = 'Y' THEN 'true'
            WHEN rt.infusion_date_estimator = 'N' THEN 'false'
            ELSE NULL END  AS IsDateEstimate,
       vtc.description AS TreatmentCategory,
       vtn.description AS TreatmentName,
       rt.description AS Description,
       rt.object_id AS ObjectId,
       rt.entry_date_tm AS Modified,
       dbo.f_map_username(rt.user_name) AS ModifiedBy,
       COALESCE(tc.created, rt.entry_date_tm) AS Created ,
       COALESCE(tc.createdby, dbo.f_map_username(rt.user_name)) AS CreatedBy,
       rt.timestamp AS Timestamp
FROM exposure.dbo.research_treatments AS rt
         LEFT OUTER JOIN exposure.dbo.valid_tr_categories as vtc on vtc.treatment_category_id = rt.treatment_category_id
         LEFT OUTER JOIN exposure.dbo.valid_tr_names as vtn on vtn.treatment_name_id = rt.treatment_name_id
         LEFT OUTER JOIN exposure.dbo.valid_institutions as vi on vi.institution_id = rt.responsible_institution_id
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = rt.object_id
         INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = rt.id

    GO

GRANT SELECT ON labkey_etl.v_exp_research_treatments TO z_labkey
    GO

