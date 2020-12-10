SELECT a.lsid,
       a.Id,
       a.Date,
       cast(a."alopeciaScore::Value" as double) as alopeciaScore,
       ltrim(a."scorer::Value") as scorer,
       a.EventId,
       a.QcState,
       a.CreatedBy,
       a.Created,
       a.ModifiedBy,
       a.Modified,
       a.ObjectId

FROM study.SndAlopecia as a
