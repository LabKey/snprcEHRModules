/*
 * Copyright (c) 2015-2016 LabKey Corporation
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

SELECT d.id,
-- special handling for colonies and pedigrees
case when agc.description like '%colonies%' then 'Colony'
         when agc.description like '%pedigree%' then 'Pedigree' else agc.description end as category,
         cast(group_concat(ag.name) as varchar(128)) as animal_group

FROM study.demographics as d
INNER JOIN study.animal_group_members AS agm on d.id = agm.id
INNER JOIN snprc_ehr.animal_groups AS ag ON agm.groupId = ag.code
INNER JOIN snprc_ehr.animal_group_categories AS agc ON agc.category_code = ag.category_code

WHERE agm.enddate is null
AND agm.qcstate.publicdata = true

group by d.id,
      case when agc.description like '%colonies%' then 'Colony'
           when agc.description like '%pedigree%' then 'Pedigree' else agc.description end

PIVOT animal_group BY category IN
(select case when description like '%colonies%' then 'Colony'
             when description like '%pedigree%' then 'Pedigree' else description end as description
 	from snprc_ehr.animal_group_categories )