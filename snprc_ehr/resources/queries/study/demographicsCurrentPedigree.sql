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
INNER JOIN ehr.animal_groups ag ON (ag.RowId = agm.GroupId AND ag.Category = 'Pedigree')
WHERE agm.isActive = true and agm.qcstate.PublicData = true
