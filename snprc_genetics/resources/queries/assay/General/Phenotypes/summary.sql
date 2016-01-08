SELECT
d.subjectId,
d.subjectId.DataSet.demographics.species,
d.SAMPLE_ID,
d.BLEED_DATE,
d.ASSAY,
d.VALUE,
d.Run,
d.folder,
CASE
WHEN d.BLEED_DATE IS NULL THEN NULL
WHEN d.BLEED_DATE IS NULL THEN NULL
ELSE (ROUND(CONVERT(age_in_months(d.subjectId.DataSet.demographics.birth, COALESCE(d.subjectId.DataSet.demographics.lastDayAtCenter, d.BLEED_DATE)), DOUBLE) / 12, 1))
END as ageAtTime
FROM Data d