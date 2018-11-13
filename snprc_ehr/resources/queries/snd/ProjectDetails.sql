SELECT p.ProjectId,
       p.RevisionNum,
       p.VsNumber,
       p.StartDate,
       p.EndDate,
       p.Active,
       p.ProjectType,
       p.ReferenceId.project as ChargeId,
       p.description as Description,
       p.ReferenceId.protocol as Iacuc,
       p.ReferenceId.protocol.veterinarian as veterinarian
from snd.Projects as p
where p.ReferenceId < 4000 and p.ReferenceId > 0
and p.Active = true
and p.ReferenceId.protocol is not null
and now() between p.StartDate and coalesce(p.EndDate, now())

