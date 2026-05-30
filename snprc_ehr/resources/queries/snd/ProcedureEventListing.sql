/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    e.EventId,
    e.SubjectId,
    e.Date,
    c.HtmlNarrative,
    COALESCE(e.AdmitId, e.ParentObjectId.ReferenceId) AS AdmitChargeId,

FROM snd.Events e
         left outer join snd.Projects p
                         on e.ParentObjectId = p.ObjectId
         left outer join ehr.project ep
                         on p.ReferenceId = ep.project
         left outer join snd.EventsCache c
                         on c.EventId = e.EventId
