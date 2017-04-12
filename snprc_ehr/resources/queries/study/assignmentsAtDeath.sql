/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */



SELECT
a.Id as id,
group_concat(a.protocol, ', ') as assignmentsAtDeath,

FROM assignment as a
INNER JOIN study.deaths as d on d.id = a.id and d.date >= a.date AND (a.enddate IS NULL OR d.date <= a.enddate)

GROUP BY a.Id