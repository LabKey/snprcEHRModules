ALTER VIEW [labkey_etl].[v_sndPackages] AS
(
SELECT p.PKG_ID AS pkgId,
	   p.DESCRIPTION AS Description,
       CASE WHEN p.REPEATABLE_FLAG = 'Y' THEN 1 ELSE 0 END AS Repeatable,
       CASE WHEN p.DISPLAYABLE_FLAG = 'Y' THEN 1 ELSE 0 END AS Active,
       p.NARRATIVE as Narrative,
       p.USDA_CATEGORY as UsdaCode,
	   tc.created AS Created,
	   dbo.f_map_username(TC.createdBy) AS CreatedBy,
	   p.ENTRY_DATE_TM AS Modified,
	   dbo.f_map_username(p.USER_NAME) AS ModifiedBy,
       p.OBJECT_ID AS ObjectId
FROM dbo.PKGS AS p
INNER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = p.OBJECT_ID
);
GO

GRANT SELECT ON Labkey_etl.v_sndPackages TO z_labkey
GO