SELECT e.EventId,
       e.AdmitId,
       c.problem as Diagnosis,
       c.admitcomplaint as AdmittingComplaint,
       c.date as AdmitDate,
       c.enddate as ReleaseDate,
       c.AssignedVet,
       c.Resolution,
       e.ParentObjectId.ReferenceId as ChargeId,
       e.ParentObjectId.ReferenceId.protocol as Protocol,
       e.ParentObjectId.ReferenceId.displayName as IacucDescription,
       a.date as AssignmentDate,
       e.ParentObjectId.ReferenceId.title as Description,
       e.ParentObjectId.ReferenceId.protocol.veterinarian as Veterinarian,

FROM Events e left outer join study.cases c on e.AdmitId = c.caseid
left join study.assignment a on a.protocol = e.ParentObjectId.ReferenceId.protocol and e.Date between a.date and coalesce(a.enddate, curdate()) and a.id = e.subjectID