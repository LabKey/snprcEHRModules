/*
 * Copyright (c) 2015 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
asn.Id as id,
group_concat(asn.protocol, ', ') as assignmentsAtDeath,

FROM assignment as asn
WHERE asn.Id.DataSet.deaths.date >= asn.date AND (asn.enddate IS NULL OR asn.Id.DataSet.deaths.date <= asn.enddate)

GROUP BY asn.Id