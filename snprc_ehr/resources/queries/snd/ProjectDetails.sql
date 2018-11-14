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
SELECT p.ProjectId,
       p.RevisionNum,
       p.VsNumber,
       p.StartDate,
       p.EndDate,
       p.Active,
       p.ProjectType,
       p.ReferenceId.project as ChargeId,
       p.description as Description,
       p.ReferenceId.protocol as Iacuc,
       p.ReferenceId.protocol.veterinarian as veterinarian
from snd.Projects as p
where p.ReferenceId < 4000 and p.ReferenceId > 0
and p.Active = true
and p.ReferenceId.protocol is not null
and now() between p.StartDate and coalesce(p.EndDate, now())

