/********************************************************
  Query will feed the export ETL back to CAMP.

02.19.21 srr
straight pull from snd.Pkgs table

 ********************************************************/
SELECT  p.PkgId,
        p.Description,
        p.Active,
        p.Repeatable,
        p.ObjectId,
        p.Container,
        p.CreatedBy,
        p.Created,
        p.ModifiedBy,
        p.Modified,
        p.Lsid,
        p.Narrative,
        p.QcState
FROM snd.Pkgs p