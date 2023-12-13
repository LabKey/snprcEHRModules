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