SELECT d.lsid,
       d.SubjectId  as Id,
       d.Date,
       d.FloatValue as BCS,
       cast(substring(bcs.Value, 1, locate(' ', bcs.Value)) as float) as  BCSValue,
       d.QcState,
       d.Event.CreatedBy,
       d.Event.Created,
       d.Event.ModifiedBy,
       d.Event.Modified,
       d.Event.ObjectId
FROM SND.DataByCategory as d
INNER JOIN snd.BCS as bcs on bcs.LookupId = cast(d.FloatValue as INTEGER)
WHERE CategoryName = 'BCS' AND QcState.publicdata = true

