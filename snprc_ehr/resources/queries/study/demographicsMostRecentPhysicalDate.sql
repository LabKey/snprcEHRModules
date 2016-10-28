/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
select
  d.Id,
  p2.lastDate as MostRecentPyhsicalDate,
  case
    WHEN p2.lastDate IS NULL THEN 9999
    ELSE age_in_months(p2.lastDate, now())
  END AS MonthsSinceLastPhysical,

from study.demographics d

LEFT JOIN (select p.id, p.pkgId, max(p.date)as lastDate
  from study.procedure as p

  left join snprc_ehr.package_category_junction as pcj on pcj.packageId = p.pkgId
  inner join snprc_ehr.package_category as pc on pcj.categoryId = pc.id and lower(pc.description) = 'physical'

  WHERE p.qcstate.publicdata = true group by p.id, p.pkgId
  )
  as p2 ON (d.id = p2.id)