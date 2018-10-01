SELECT p.ProjectId,
       p.RevisionNum,
       p.VsNumber,
       p.StartDate,
       p.EndDate,
       p.Active,
       p.ProjectType,
       p.ReferenceId.project as ChargeId,
       p.description as Description,
       p.ReferenceId.protocol as Iacuc
from snd.Projects as p
