/********************************************************
  Query will feed the export ETL back to CAMP.

02.22.21 srr
Has objectID

 ********************************************************/
SELECT pi.ProjectItemId as budget_item_id,
       p.ProjectId as budget_id,
       p.RevisionNum as revision_num,
       pi2.ProjectItemId as parent_budget_item_id,
       pi.ParentObjectId,
       pi.SuperPkgId,
       pi.Active,
       pi.Container,
       pi.CreatedBy,
       pi.Created,
       pi.ModifiedBy,
       pi.Modified,
       pi.Lsid,
       pi.Objectid

FROM snd.ProjectItems pi
INNER JOIN snd.Projects as p on pi.ParentObjectId = p.ObjectId
LEFT JOIN snd.SuperPkgs as sp on pi.SuperPkgId = sp.SuperPkgId
LEFT JOIN snd.ProjectItems as pi2 on sp.parentSuperPkgId = pi2.SuperPkgId and pi.ParentObjectId = p.ObjectId

