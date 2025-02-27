SELECT
    t.LSID as _key,
    t.SubjectId as participantid,
    t.tb_site as site,
    t.tb_result as result,
    t.date,
    null as taskid,
    null as requestid,
    null as performedby,
    null as description,
    null as remark,
    p.ReferenceId as project,
    t.QcState,
    t.SequenceNum,
    t.ObjectId,
    t.EventDataId,
    t.EventId,
    t.SuperPkgId,
    t.ObjectURI,
    t.Container,
    t.ParentEventDataId,
    t.SortOrder,
    t.USDACode,
    t.LSID,
    e.CreatedBy,
    e.Created,
    e.ModifiedBy,
    e.Modified

FROM SND.Categories.TB as t
         INNER JOIN SND.Events as e on t.EventId = e.EventId
         INNER JOIN SND.Projects as p on e.ParentObjectId = p.objectId