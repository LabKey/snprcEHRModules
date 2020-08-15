
SELECT
LSID as LSID,
EventData.EventId.SubjectId as Id,
EventData.EventId.Date,
FloatValue as weight,
EventId,
EventId.QcState
FROM SND.DataByCategory
WHERE Category = 'Weight'