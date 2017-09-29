CREATE VIEW [labkey_etl].[v_delete_PkgCategories] AS

-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 9/27/2017
-- Description: Selects the records to delete from snd.PkgCategories dataset
-- Changes:
--
--
-- ==========================================================================================
SELECT av.object_id,
	av.audit_date_tm
FROM AUDIT.AUDIT_VALID_CODE_TABLE AS av

WHERE av.audit_action = 'D' AND av.object_id IS NOT NULL
  AND   av.TABLE_NAME = 'pkg_category'
  AND av.COLUMN_NAME = 'category_code'

GO


grant SELECT on labkey_etl.v_delete_PkgCategories to z_labkey
GRANT SELECT ON audit.AUDIT_VALID_CODE_TABLE TO z_labkey

GO