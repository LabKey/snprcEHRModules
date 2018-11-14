/*
 * Copyright (c) 2017-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  d.Id AS Id,

  T1.date as MostRecentAcq,
  T1.acquisitionType.value as MostRecentAcqType,
  T1.acquisitionType.Description as MostRecentAcqDesc,

  T2.date as EarliestAcq,
  T2.acquisitionType.value as EarliestAcqType,
  T2.acquisitionType.Description as EarliestAcqDesc,

  coalesce(T2.date, d.birth) as Center_Arrival,

FROM study.demographics d



--date of most recent arrival
LEFT JOIN study.arrival as t1 on t1.id = d.id and T1.qcstate.publicdata = true
   and T1.date = (select max(c1.date) from study.arrival as c1
                  where t1.id = c1.id)


--date of first arrival
LEFT JOIN study.arrival as t2 on t2.id = d.id and T2.qcstate.publicdata = true
   and t2.date = (select min(c1.date) from study.arrival as c1
                  where t2.id = c1.id)