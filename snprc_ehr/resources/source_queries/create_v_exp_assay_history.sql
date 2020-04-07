ALTER VIEW labkey_etl.v_exp_assay_history AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2020
-- Description:	Selects the assay_history data for LK ETL
-- Note:
--
-- Changes:
--
-- ==========================================================================================

SELECT ah.id,
       ah.assay_date as date,
       ah.bleed_date as bleed_date,
       CASE WHEN ah.bleed_date_estimator = 'Y' THEN 'true'
            WHEN ah.bleed_date_estimator = 'N' THEN 'false'
            ELSE NULL END  AS isBleedDateEstimate,
       val.description AS lab,
       vak.description AS kit,
       vst.assay_type AS assay_type,
       vst.summary_class AS summary_class,
       vst.summary_specific AS summary_specific,
       vst.isis_test_type AS isis_test_type,
       ah.out_of_range_indicator AS out_of_range_indicator,
       ah.value AS value,
       CASE WHEN ah.result = '+' THEN 'Positive'
            WHEN ah.result = '-' THEN 'Negative'
            WHEN ah.result = 'i' THEN 'Indeterminate'
            ELSE ah.result END AS result,
       ah.sample_id AS sample_id,
       ah.object_id AS objectid,
       ah.entry_date_tm AS modified,
       dbo.f_map_username(ah.user_name) AS modifiedby,
       COALESCE(tc.created, ah.entry_date_tm) AS created ,
       COALESCE(tc.createdby, dbo.f_map_username(ah.user_name)) AS createdby,
       ah.timestamp AS timestamp


FROM exposure.dbo.assay_history AS ah
         LEFT OUTER JOIN exposure.dbo.valid_assay_labs AS val ON val.lab_id = ah.lab_id
         LEFT OUTER JOIN exposure.dbo.valid_assay_kits AS vak ON vak.kit_id = ah.kit_id
         LEFT OUTER JOIN exposure.dbo.valid_summary_types AS vst ON vst.summary_id = ah.summary_id
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = ah.object_id
         INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ah.id

    GO

GRANT SELECT ON labkey_etl.v_exp_assay_history TO z_labkey
    GO