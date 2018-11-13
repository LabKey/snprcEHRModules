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
SELECT
c.id,
c.date,
c."water::observation" as water,
c."feed::observation" as feed,

case when c."sa_none::observation" = 'Y' then 'None' else '' end +
case	when c."sa_unknown::observation" = 'Y' then 'Unknown' else '' end +
case	when c."sa_normal::observation" = 'Y' then 'Normal' else '' end +
case when c."sa_bloody::observation" = 'Y' then ' Bloody' else '' end +
case when c."sa_dry::observation" = 'Y' then ' Dry' else '' end +
case when c."sa_loose::observation" = 'Y' then ' Loose' else '' end +
case when c."sa_other::observation" = 'Y' then ' Other' else '' end +
case when c."sa_soft::observation" = 'Y' then ' Soft' else '' end +
case when c."sa_pellet::observation" = 'Y' then ' Pellet' else '' end +
case when c."sa_watery::observation" = 'Y' then ' Watery' else '' end as stool,
COALESCE (c."housing_status::observation", '0') as housing_status,
COALESCE (c."comments::observation", ' ') as comments,
c.performedby


FROM (

SELECT
  co.id,
  co.date,
  LEFT(co.objectid, 37 ) as objectid,
  co.category as category,
  max(co.observation) as observation,
  max(performedby) as performedby

FROM study.clinical_observations co
INNER JOIN snprc_ehr.clinical_observation_datasets as cod on co.category = cod.category_name and cod.dataset_name = 'daily_obs'
WHERE co.qcstate.publicdata = true

GrOUP BY co.id, co.date, LEFT(co.objectid, 37 ), co.category, performedby

PIVOT  observation BY category IN
   (select category_name from snprc_ehr.clinical_observation_datasets where dataset_name = 'daily_obs' order by sort_order)
 ) as c

order by id, date desc