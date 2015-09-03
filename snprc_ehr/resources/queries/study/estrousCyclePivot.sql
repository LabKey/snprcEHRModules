/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
c.id,
c.date,
group_concat('Estrous data: ', chr(10)) as servicerequested,
c.category,
group_concat(cast(c.observation as varchar)) as observations

FROM (

SELECT
  co.id,
  co.date,
  LEFT(co.objectid, 37 ) as objectid,
  co.category,
  co.observation,
FROM study.clinical_observations co
WHERE co.qcstate.publicdata = true
) c

GROUP BY c.id, c.date, c.category, c.objectid
PIVOT  observations BY category IN
(  'tumescence_index', 'vaginal_bleeding', 'purple_color' , 'carrying_infant', 'male_status', 'male_id', 'cycle_location', 'observer_emp_num')