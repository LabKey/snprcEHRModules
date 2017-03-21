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
  agm.id,
  agm.date,
  agm.groupId.name as pedigree

FROM study.animal_group_members as agm
INNER JOIN snprc_ehr.animal_groups as ag ON ag.code = agm.groupId
INNER JOIN snprc_ehr.animal_group_categories as agc on ag.category_code = agc.category_code and agc.description like '%pedigree%'
WHERE agm.isActive = true and agm.qcstate.PublicData = true
