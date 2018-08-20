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
SELECT d.Id,
  d.id.curLocation.room.area as area,
  d.id.curLocation.room as Location,
  d.gender as Sex,
  d.id.age.ageInYears as Age,
  d.species.arc_species_code as Species,
  d.id.MostRecentTBDate.MostRecentTBDate as LastTB,
  d.id.MostRecentTBDate.DaysSinceLastTB DaysSinceLastTB,
  d.id.MostRecentTBDate.TbStatus as TBStatus,
  p.MostRecentPyhsicalDate as LastPhysical,
  p.DaysSinceLastPhysical as DaysSinceLastPhysical,
  p.PhyStatus as PhysicalStatus

FROM demographics d
left join study.demographicsMostRecentPhysicalDate as p on p.id = d.id
--left join study.animal_group_members as agm on agm.id = d.id and agm.groupId.category_code.description = 'Misc Colonies' and agm.enddate is null
where d.calculated_status = 'Alive'
  --and agm.groupId.Name is null
  and d.species.arc_species_code not in ('CJ', 'SM', 'RA', 'MD', 'RB', 'PT', 'CL')
  and d.id.curLocation.room not in ('0.0', '100.01', '105.00', '35.02') -- exclude corrals, unknown & BSL4
  and ( d.id.MostRecentTBDate.TbStatus <> 'Okay' or p.phyStatus <> 'Okay')
order by d.id.curLocation.room asc, id asc
