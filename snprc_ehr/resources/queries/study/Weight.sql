SELECT lsid,
       SubjectId  as Id,
       Date,
       FloatValue as weight,
       QcState,
       Event.CreatedBy,
       Event.Created,
       Event.ModifiedBy,
       Event.Modified,
       Event.ObjectId
FROM SND.DataByCategory
WHERE CategoryName = 'Weight'
