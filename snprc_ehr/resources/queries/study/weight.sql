
SELECT
lsid,
SubjectId as Id,
Date,
FloatValue as weight,
QcState
FROM SND.DataByCategory
WHERE CategoryName = 'Weight'