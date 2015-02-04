/*
 * Copyright (c) 2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

d.id,
group_concat(DISTINCT d2.id) as Offspring,
count(DISTINCT d2.id) as TotalOffspring,
SUM(CASE WHEN d2.calculated_status = 'Alive' THEN 1 ELSE 0 END) as TotalLivingOffspring,

min(d2.birth) as earliestBirth,
max(d2.birth) as latestBirth

FROM study.Demographics d

JOIN study.Demographics d2
  ON (d.id = d2.id.parents.sire OR d.id = d2.id.parents.dam)

GROUP BY d.id

UNION

SELECT

d3.id,
NULL as Offspring,
0 as TotalOffspring,
0 as TotalLivingOffspring,

NULL as earliestBirth,
NULL as latestBirth

FROM study.Demographics d3

WHERE (d3.id NOT IN (
   SELECT d4.id.parents.sire FROM study.demographics d4 WHERE (d4.id.parents.sire IS NOT NULL)
   UNION
   SELECT d4.id.parents.dam FROM study.demographics d4 WHERE (d4.id.parents.dam IS NOT NULL)))

GROUP BY d3.id
