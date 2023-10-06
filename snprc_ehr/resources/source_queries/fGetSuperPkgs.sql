USE animal
GO
/****** Object:  UserDefinedFunction snd.fGetSuperPkg    Script Date: 10/5/2023 4:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION labkey_etl.fGetSuperPkg ( @TopLevelPkgId INT )
RETURNS TABLE
AS

RETURN
    (
   WITH    CTE1 ( TopLevelPkgId, SuperPkgId, ParentSuperPkgId, PkgId, SuperPkgPath, SortOrder, Required, DESCRIPTION, Narrative, Active, Repeatable, Level,
				  Modified, ModifiedBy, Created, CreatedBy, ObjectId)
              AS (


                   SELECT   @TopLevelPkgId AS TopLevelPkgId ,
                            sp.Super_Pkg_Id AS SuperPkgId ,
                            spp.PARENT_SUPER_PKG_ID AS ParentSuperPkgId ,
                            sp.Pkg_Id AS PkgId ,
                            RIGHT(SPACE(3)
                                  + CONVERT(VARCHAR(MAX), ROW_NUMBER() OVER ( ORDER BY sp.ORDER_NUM )),
                                  3) AS SuperPkgPath,
                            COALESCE(sp.ORDER_NUM, 0) AS SortOrder ,
                            0 AS Required ,
                            p.Description AS Description ,
                            p.Narrative AS Narrative ,
                            CASE WHEN p.DISPLAYABLE_FLAG = 'Y' THEN 1 ELSE 0 END AS Active ,
                            CASE WHEN p.REPEATABLE_FLAG = 'Y' THEN 1 ELSE 0 END AS Repeatable ,
                            1 AS Level,
							COALESCE(tc.created, sp.ENTRY_DATE_TM) AS Created,
							COALESCE(tc.createdby, sp.USER_NAME) AS CreatedBy,
							sp.ENTRY_DATE_TM AS Modified,
							sp.USER_NAME AS ModifiedBy,
							sp.OBJECT_ID AS ObjectId
                   FROM     dbo.Super_Pkgs sp
				   INNER JOIN dbo.PKGS AS p ON p.PKG_ID = sp.PKG_ID
                   INNER JOIN dbo.v_superPackageParents AS spp ON sp.SUPER_PKG_ID = spp.SUPER_PKG_ID
				   LEFT JOIN dbo.TAC_COLUMNS AS tc ON sp.OBJECT_ID = tc.object_id
                   WHERE    sp.Pkg_Id = @TopLevelPkgId
                            AND sp.PARENT_PKG_ID IS NULL
                   UNION ALL
                   SELECT   @TopLevelPkgId AS TopLevelPkgId ,
                            sp.Super_Pkg_Id AS SuperPkgId ,
                            c.SuperPkgId AS ParentSuperPkgId ,
                            sp.Pkg_Id AS PkgId ,
                            c.SuperPkgPath + '/' + RIGHT(SPACE(3)
                                                     + CONVERT(VARCHAR(MAX), RIGHT(ROW_NUMBER() OVER ( ORDER BY sp.ORDER_NUM ),
                                                              10)), 3) AS SuperPkgPath ,
                            sp.ORDER_NUM AS SortOrder ,
                            0 AS Required ,
                            p.Description AS Description ,
                            p.Narrative AS Narrative ,
                            CASE WHEN p.DISPLAYABLE_FLAG = 'Y' THEN 1 ELSE 0 END AS Active ,
                            CASE WHEN p.REPEATABLE_FLAG = 'Y' THEN 1 ELSE 0 END AS Repeatable ,
                            c.Level + 1 AS Level,
							c.created AS Created,
							c.createdby AS CreatedBy,
							c.Modified AS Modified,
							c.ModifiedBy AS ModifiedBy,
							c.ObjectId
                   FROM     dbo.SUPER_PKGS AS sp
				   INNER JOIN dbo.PKGS AS p ON sp.Pkg_Id = p.Pkg_Id
				   INNER JOIN dbo.v_superPackageParents AS spp ON sp.SUPER_PKG_ID = spp.SUPER_PKG_ID
                   INNER JOIN CTE1 AS c ON spp.PARENT_SUPER_PKG_ID = c.SuperPkgId
						  OR EXISTS (SELECT  1
							FROM dbo.v_superPackageParents AS spp2
							WHERE c.PkgId = spp2.Pkg_Id AND spp2.PARENT_SUPER_PKG_ID IS NULL
							AND spp.PARENT_SUPER_PKG_ID = spp.SUPER_PKG_ID
							)

                 )
    SELECT  @TopLevelPkgId AS TopLevelPkgId ,
            c.SuperPkgId AS SuperPkgId ,
            c.ParentSuperPkgId AS ParentSuperPkgId ,
            c.PkgId AS PkgId ,
            c.SuperPkgPath AS SuperPkgPath ,
            c.SortOrder AS SortOrder ,
            c.Required AS Required ,
            c.DESCRIPTION AS Description ,
            c.Narrative AS Narrative ,
            c.Active AS Active ,
            c.Repeatable AS Repeatable ,
            c.Level AS Level,
			c.Created,
			c.CreatedBy,
			c.Modified,
			c.ModifiedBy,
			c.ObjectId
    FROM    CTE1 c

);