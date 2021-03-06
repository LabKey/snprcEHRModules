/********************************************************
  Query will feed the export ETL back to CAMP.

02.24.21 srr
straight pull from snd.PkgCategories table

 ********************************************************/

SELECT pc.CategoryId,
       pc.Description,
       pc.Comment,
       pc.Active,
       pc.SortOrder,
       pc.Container,
       pc.CreatedBy,
       pc.Created,
       pc.ModifiedBy,
       pc.Modified,
       pc.Lsid,
       pc.Objectid
FROM snd.PkgCategories pc