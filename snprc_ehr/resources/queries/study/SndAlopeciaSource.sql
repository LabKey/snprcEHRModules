SELECT
    a.LSID as _key,
    a.SubjectId as participantid,
    a.date,
    a.alopeciaScore,
    a.scorer,
    p.ReferenceId as project,
    null as taskid,
    null as requestid,
    null as performedby,
    null as description,
    null as remark,
    a.QcState,
    a.SequenceNum,
    a.ObjectId,
    a.EventDataId,
    a.EventId,
    a.SuperPkgId,
    a.ObjectURI,
    a.Container,
    a.ParentEventDataId,
    a.SortOrder,
    a.USDACode,
    a.LSID,
    e.CreatedBy,
    e.Created,
    e.ModifiedBy,
    e.Modified

FROM SND.Categories.Alopecia as a
         INNER JOIN SND.Events as e on a.EventId = e.EventId
         INNER JOIN SND.Projects as p on e.ParentObjectId = p.objectId