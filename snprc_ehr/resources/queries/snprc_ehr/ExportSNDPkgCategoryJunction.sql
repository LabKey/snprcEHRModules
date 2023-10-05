/********************************************************
  Query will feed the export ETL back to CAMP.

03.04.21 srr

Changed CreatedBy and ModifiedBy to user DisplayName
  08.19.21  srr
 ********************************************************/

SELECT pcj.PkgId,
       pcj.CategoryId,
       pcj.Container,
       pcj.CreatedBy.DisplayName as CreatedBy,
       pcj.Created,
       pcj.ModifiedBy.DisplayName as ModifiedBy,
       pcj.Modified,
       pcj.Lsid,
       pcj.Objectid
FROM snd.PkgCategoryJunction pcj