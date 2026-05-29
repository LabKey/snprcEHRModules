/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    w.LSID as _key,
    w.SubjectId as participantid,
    w.date,
    w.weight,
    p.ReferenceId as project,
    null as taskid,
    null as requestid,
    null as performedby,
    null as description,
    null as remark,
    w.QcState,
    w.SequenceNum,
    w.ObjectId,
    w.EventDataId,
    w.EventId,
    w.SuperPkgId,
    w.ObjectURI,
    w.Container,
    w.ParentEventDataId,
    w.SortOrder,
    w.USDACode,
    w.LSID,
    e.CreatedBy,
    e.Created,
    e.ModifiedBy,
    e.Modified
FROM SND.Categories.Weight as w
         INNER JOIN SND.Events as e on w.EventId = e.EventId
         INNER JOIN SND.Projects as p on e.ParentObjectId = p.objectId