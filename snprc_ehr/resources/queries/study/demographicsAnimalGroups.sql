/*
 * Copyright (c) 2013-2014 LabKey Corporation
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
  d.id,
  (SELECT MIN(cag.RowId)) AS ColonyGroup,
  (SELECT MIN(bag.RowId)) AS BreedingGroup

FROM study.demographics d
LEFT JOIN ehr.animal_group_members cagm ON (cagm.Id = d.Id AND cagm.isActive = true)
LEFT JOIN ehr.animal_groups cag ON (cag.RowId = cagm.GroupId AND cag.Category = 'Colony')
LEFT JOIN ehr.animal_group_members bagm ON (bagm.Id = d.Id AND bagm.isActive = true)
LEFT JOIN ehr.animal_groups bag ON (bag.RowId = bagm.GroupId AND bag.Category = 'Breeding')

GROUP BY d.Id