/*
 * Copyright (c) 2018 LabKey Corporation
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
SELECT a.Id,
       p.ProjectId,
       p.RevisionNum,
       a.date as StartDate,
       a.endDate as EndDate,
       a.Id.MostRecentWeight.MostRecentWeight as Weight,
       a.Id.Age.ageFriendly as Age,
       a.Id.Demographics.Gender as Gender,
       ep.project as ChargeId,
       ep.protocol as Iacuc,
       a.id.curLocation.room as location,
       a.id.curLocation.cage as cage,
       a.assignmentStatus as AssignmentStatus
from snd.Projects as p
       INNER JOIN ehr.project as ep on p.ReferenceId = ep.project
       INNER JOIN study.assignment as a on ep.protocol = a.protocol
where p.ReferenceId < 4000 and p.ReferenceId > 0
  and p.Active = true
  and ep.protocol is not null
  and now() between p.StartDate and coalesce(p.EndDate, now())
  and now() between a.date and coalesce(a.endDate, now())
  and a.assignmentStatus in ('A', 'S')