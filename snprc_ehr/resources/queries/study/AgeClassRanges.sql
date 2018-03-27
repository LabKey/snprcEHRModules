SELECT age.species,
  age.ageclass,
  age.label,
  CAST(age."min" as VARCHAR(5)) + '.0 - ' + CAST(age."max" as VARCHAR(5)) +'.0'  AS ageRange,
  age.gender

FROM ehr_lookups.ageclass AS age

