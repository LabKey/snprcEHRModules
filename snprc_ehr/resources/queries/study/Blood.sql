SELECT b.lsid,
       b.Id,
       b.Date,
       cast(b."blood_volume::Value" as double) as Quantity,
       ltrim(b."Reason::Value") as Reason,
       b.EventId,
       b.QcState,
       coalesce(b.IACUC, 'Non-research') as IACUC,
       cast(b.Date as date)  as dateOnly,
       b.Project,
       true as countsAgainstVolume,
       b.CreatedBy,
       b.Created,
       b.ModifiedBy,
       b.Modified,
       b.ObjectId

FROM study.SndBlood as b


