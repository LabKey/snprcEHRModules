/*
 * Copyright (c) 2010-2011 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  d.Id AS Id,

  T1.date as MostRecentDisp,
  T1.dispositionType.value as MostRecentDispType,
  T1.dispositionType.Description as MostRecentDispDesc,

  T2.date as EarliestDisp,
  T2.dispositionType.value as EarliestDispType,
  T2.dispositionType.Description as EarliestDispDesc

FROM study.demographics d



--date of most recent disposition
LEFT JOIN study.departure as t1 on t1.id = d.id and T1.qcstate.publicdata = true
   and T1.date = (select max(c1.date) from study.departure as c1
                  where t1.id = c1.id)


--date of first disposition
LEFT JOIN study.departure as t2 on t2.id = d.id and T2.qcstate.publicdata = true
   and t2.date = (select min(c1.date) from study.departure as c1
                  where t2.id = c1.id)