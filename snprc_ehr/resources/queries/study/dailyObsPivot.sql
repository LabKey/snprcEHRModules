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
--'Daily Observations: '  as servicerequested,
c.category,
group_concat(cast(c.observation as varchar)) as observations,

FROM (

SELECT
  co.id,
  co.date,
  LEFT(co.objectid, 37 ) as objectid,
  co.category,
  co.observation,
FROM study.clinical_observations co
INNER JOIN snprc_ehr.clinical_observation_datasets as cod on co.category = cod.category_name and cod.dataset_name = 'daily_obs'
WHERE co.qcstate.publicdata = true
) c

GROUP BY c.id, c.date, c.category, c.objectid

PIVOT  observations BY category IN
(select category_name from snprc_ehr.clinical_observation_datasets where dataset_name = 'daily_obs' order by sort_order)
-- (	'water', 'feed','sa_none', 'sa_bloody','sa_dry', 'sa_loose', 'sa_normal', 'sa_other',
--	   'sa_pellet', 'sa_soft' ,  'sa_unknown','sa_watery', 'housing_status', 'comments')
order by id, date desc