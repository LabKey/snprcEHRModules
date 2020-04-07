CREATE VIEW labkey_etl.v_exp_blood_products AS
    -- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2020
-- Description:	Selects the blood_products data for LK ETL
-- Note:
--
-- Changes:
--
-- ==========================================================================================

SELECT bp.id AS id,
       bp.doi AS date,
       CASE WHEN bp.doi_estimator = 'Y' THEN 'true'
            WHEN bp.doi_estimator = 'N' THEN 'false'
            ELSE NULL END  AS isDateEstimate,
       pc.description AS productCategory,
       pt.description AS productType,
       bp.description AS description,
       bp.object_id AS objectid,
       bp.entry_date_tm AS modified,
       dbo.f_map_username(bp.user_name) AS modifiedby,
       COALESCE(tc.created, bp.entry_date_tm) AS created ,
       COALESCE(tc.createdby, dbo.f_map_username(bp.user_name)) AS createdby,
       bp.timestamp AS timestamp
FROM exposure.dbo.blood_products AS bp
         INNER JOIN exposure.dbo.valid_bld_pr_categories AS pc ON pc.product_category_id = bp.product_category_id
         INNER JOIN exposure.dbo.valid_bld_pr_types AS pt ON bp.product_type_id = pt.product_type_id
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = bp.object_id
         INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = bp.id

    GO

GRANT SELECT ON labkey_etl.v_exp_blood_products TO z_labkey
    GO