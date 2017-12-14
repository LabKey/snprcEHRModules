/*
 * Copyright (c) 2010-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

d.id,
ac.AgeClass,
ac.label,
d.gender

FROM study.demographics d
LEFT JOIN ehr_lookups.ageclass ac
ON (
  (CONVERT(age_in_months(d.birth, COALESCE(d.death, now())), DOUBLE) / 12) >= ac."min" AND
  ((CONVERT(age_in_months(d.birth, COALESCE(d.death, now())), DOUBLE) / 12) < ac."max" OR ac."max" is null) AND
  d.species.arc_species_code.code = ac.species AND
  (d.gender = ac.gender OR ac.gender IS NULL)
)
WHERE d.birth IS NOT NULL
