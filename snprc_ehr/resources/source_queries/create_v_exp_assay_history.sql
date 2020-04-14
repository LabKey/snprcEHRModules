ALTER VIEW labkey_etl.v_exp_assay_history AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2020
-- Description:	Selects the assay_history data for LK ETL
-- Note:
--
-- Changes:
-- 4/7/2020 Fixed camel casing and correct date column. tjh
-- 4/8/2020 changed camel casing to title casing. tjh
-- ==========================================================================================

SELECT ah.id as Id,
       ah.bleed_date as Date,
       CASE WHEN ah.bleed_date_estimator = 'Y' THEN 'true'
            WHEN ah.bleed_date_estimator = 'N' THEN 'false'
            ELSE NULL END  AS IsDateEstimate,
       ah.assay_date as AssayDate,
       val.description AS Lab,
       vak.description AS Kit,
       vst.assay_type AS AssayType,
       vst.summary_class AS SummaryClass,
       vst.summary_specific AS SummarySpecific,
       vst.isis_test_type AS IsisTestType,
       CASE WHEN ah.out_of_range_indicator = 'Y' THEN 'true'
            WHEN ah.out_of_range_indicator = 'N' THEN 'false'
            ELSE NULL END  AS OutOfRangeIndicator,
       ah.value AS Value,
       CASE WHEN ah.result = '+' THEN 'Positive'
            WHEN ah.result = '-' THEN 'Negative'
            WHEN ah.result = 'i' THEN 'Indeterminate'
            ELSE ah.result END AS Result,
       ah.sample_id AS SampleId,
       ah.object_id AS ObjectId,
       ah.entry_date_tm AS Modified,
       dbo.f_map_username(ah.user_name) AS ModifiedBy,
       COALESCE(tc.created, ah.entry_date_tm) AS Created ,
       COALESCE(tc.createdby, dbo.f_map_username(ah.user_name)) AS CreatedBy,
       ah.timestamp AS Timestamp


FROM exposure.dbo.assay_history AS ah
         LEFT OUTER JOIN exposure.dbo.valid_assay_labs AS val ON val.lab_id = ah.lab_id
         LEFT OUTER JOIN exposure.dbo.valid_assay_kits AS vak ON vak.kit_id = ah.kit_id
         LEFT OUTER JOIN exposure.dbo.valid_summary_types AS vst ON vst.summary_id = ah.summary_id
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = ah.object_id
         INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ah.id

    GO

GRANT SELECT ON labkey_etl.v_exp_assay_history TO z_labkey
    GO