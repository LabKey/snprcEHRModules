CREATE VIEW [labkey_etl].[v_snd_PkgCategories] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 09/27/2017
-- Description:	selects the package_category data for the SND integration to snprc_ehr
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT
  vct.code                          AS CategoryId,
  vct.DESCRIPTION                   AS Description,
  CASE WHEN vct.END_DATE_TM IS NULL THEN 1 ELSE 0 END AS Active,
  vct.SORT_ORDER AS SortOrder,
  vct.object_id                     AS objectid,
  vct.entry_date_tm                 AS modified,
  dbo.f_map_username(vct.user_name) AS modifiedby,
  tc.created                        AS created,
  tc.createdby                      AS createdby,
  vct.timestamp                     AS timestamp
FROM dbo.valid_code_table AS vct
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = vct.object_id
WHERE vct.TABLE_NAME = 'pkg_category'
      AND vct.COLUMN_NAME = 'category_code'
      AND vct.END_DATE_TM IS NULL


GO
GRANT SELECT ON [labkey_etl].[v_snd_PkgCategories] TO z_labkey

GO

