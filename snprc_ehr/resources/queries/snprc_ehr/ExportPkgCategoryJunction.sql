/********************************************************
  Query will feed the export ETL back to CAMP.

03.04.21 srr

Changed CreatedBy and ModifiedBy to user DisplayName
  Added Text to column names
    .CreatedBy.DisplayName as CreatedByText,
    .ModifiedBy.DisplayName as ModifiedByText,
  08.19.21  srr
 ********************************************************/

SELECT pcj.PkgId,
       pcj.CategoryId,
       pcj.Container,
       pcj.CreatedBy.DisplayName as CreatedByText,
       pcj.Created,
       pcj.ModifiedBy.DisplayName as ModifiedByText,
       pcj.Modified,
       pcj.Lsid,
       pcj.Objectid
FROM snd.PkgCategoryJunction pcj