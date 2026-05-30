/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    b.LSID as _key,
    b.SubjectId as participantid,
    b.date,
    b.QcState,
    b.SequenceNum,
    b.ObjectId,
    b.EventDataId,
    b.EventId,
    b.SuperPkgId,
    b.ObjectURI,
    b.Container,
    b.ParentEventDataId,
    b.SortOrder,
    b.USDACode,
    b.reason as remark,
    null as tube_type,
    null as tube_vol,
    null as num_tubes,
    b.BLOOD_Volume as quantity,
    null as additionalServices,
    null as instructions,
    null as daterequested,
    null as BloodRemaining,
    p.ReferenceId as project,
    null as taskid,
    null as parentId,
    null as requestId,
    b.LSID,
    e.CreatedBy,
    e.Created,
    e.ModifiedBy,
    e.Modified

FROM SND.Categories."Cumulative Blood" as b
         INNER JOIN SND.Events as e on b.EventId = e.EventId
         INNER JOIN SND.Projects as p on e.ParentObjectId = p.objectId