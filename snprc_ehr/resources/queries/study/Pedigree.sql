/*
 * Copyright (c) 2015-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

d.id as Id,
d.dam as Dam,
d.sire as Sire,

CASE (d.id.demographics.gender.origGender)
  WHEN 'M' THEN 1
  WHEN 'F' THEN 2
  ELSE 3
END AS gender,
d.id.demographics.gender as gender_code,
CASE (d.id.demographics.calculated_status)
  WHEN 'Alive' THEN 0
  ELSE 1
END
AS status,
d.id.demographics.calculated_status as status_code,
d.id.demographics.species.arc_species_code as species,
'' as Display,
'Demographics' as source

FROM study.demographics d
WHERE d.Dam IS NOT NULL OR d.Sire IS NOT NULL
