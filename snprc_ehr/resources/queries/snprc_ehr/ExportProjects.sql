/********************************************************
  Query will feed the export ETL back to CAMP.

02.22.21 srr
Has objectID

 ********************************************************/
SELECT p.ProjectId,
       p.RevisionNum,
       p.ReferenceId,
       p.StartDate,
       p.EndDate,
       p.Description,
       p.Active,
       p.ObjectId,
       p.Container,
       p.CreatedBy,
       p.Created,
       p.ModifiedBy,
       p.Modified,
       p.Lsid
FROM snd.Projects p