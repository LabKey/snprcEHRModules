/********************************************************
  Query will feed the export ETL back to CAMP.
 ********************************************************/
SELECT  p.PkgId as PKG_ID,
        p.Description as DESCRIPTION,
        CASE WHEN (p.Repeatable = 'true') THEN 'Y' ELSE 'N' END as REPEATABLE_FLAG,
        CASE WHEN (p.Active = 'true') THEN 'Y' ELSE 'N' END as DISPLAYABLE_FLAG,
        p.Narrative as NARRATIVE,
        NULL as EXPENSE_NARRATIVE,
        COALESCE(p.UsdaCode, 'U') as USDA_CATEGORY,
        p.ObjectId as OBJECT_ID,
        p.ModifiedBy.DisplayName as USER_NAME,
        p.Modified as ENTRY_DATE_TM
FROM snd.Pkgs p