/********************************************************
  Query will feed the export ETL back to CAMP.

02.19.21 srr
straight pull from snd.SuperPkgs table

 ********************************************************/

SELECT  sp.SuperPkgId as SUPER_PKG_ID,
        sp2.PkgId AS PARENT_PKG_ID,
        sp.PkgId AS PKG_ID,
        sp.ModifiedBy.DisplayName as USER_NAME,
        sp.Modified AS ENTRY_DATE_TM,
        COALESCE(sp.SortOrder, 0) AS ORDER_NUM
FROM  snd.SuperPkgs sp
LEFT JOIN snd.SuperPkgs sp2 on sp2.SuperPkgId = sp.ParentSuperPkgId