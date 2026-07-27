/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    b.LSID as _key,
    b.SubjectId as participantid,
    b.date,
    l.value as BCS,
    CAST(SUBSTRING(l.value, 1, CAST(locate(' -', l.value, 1) AS INTEGER)) AS varchar(4))  AS BCSValue,
    p.ReferenceId as project,
    null as taskid,
    null as requestid,
    null as performedby,
    null as description,
    null as remark,
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
    b.LSID,
    e.CreatedBy,
    e.Created,
    e.ModifiedBy,
    e.Modified

FROM SND.Categories.BCS as b
         INNER JOIN SND.LookupSets as ls on ls.SetName = 'BCS'
         INNER JOIN SND.Lookups as l on l.lookupSetId = ls.lookupSetId AND b.bcs = l.lookupId
         INNER JOIN SND.Events as e on b.EventId = e.EventId
         INNER JOIN SND.Projects as p on e.ParentObjectId = p.objectId