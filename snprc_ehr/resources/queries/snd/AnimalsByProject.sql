SELECT a.Id,
       p.ProjectId,
       p.RevisionNum,
       a.date as StartDate,
       a.endDate as EndDate,
       a.Id.MostRecentWeight.MostRecentWeight as Weight,
       a.Id.Age.ageFriendly as Age,
       a.Id.Demographics.Gender as Gender,
       p.ReferenceId.project as ChargeId,
       p.ReferenceId.protocol as Iacuc,
       a.assignmentStatus as AssignmentStatus
from snd.Projects as p
       INNER JOIN study.assignment as a on p.ReferenceId.protocol = a.protocol
where p.ReferenceId < 4000 and p.ReferenceId > 0
  and p.Active = true
  and p.ReferenceId.protocol is not null
  and now() between p.StartDate and coalesce(p.EndDate, now())
  and now() between a.date and coalesce(a.endDate, now())
  and a.assignmentStatus in ('A', 'S')