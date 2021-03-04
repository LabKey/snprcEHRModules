/********************************************************
  Query will feed the export ETL back to CAMP.

02.19.21 srr
straight pull from snd.SuperPkgs table

 ********************************************************/

SELECT  sp.SuperPkgId,
        sp.ParentSuperPkgId,
        sp.PkgId,
        sp.SuperPkgPath,
        sp.Container,
        sp.CreatedBy,
        sp.Created,
        sp.ModifiedBy,
        sp.Modified,
        sp.Lsid,
        sp.SortOrder,
        sp.Required
FROM  snd.SuperPkgs sp