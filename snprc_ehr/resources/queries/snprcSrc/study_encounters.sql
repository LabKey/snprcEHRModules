/*
 * Copyright (c) 2015 LabKey Corporation
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
s.surgery_id as Id,
s.surgery_date_tm as date,
(SELECT project FROM ehr.project p WHERE p.name = s.working_iacuc) as project,
s.description as title,
s.surgeon_name as performedby
--TODO:
--admit_id?
--surgery_level

from dbo.surgeries s

UNION ALL

select
e.Id,
e.exam_date as date,
null as project,
e.exam_type as title,
e."user_name" as performedby

from dbo.exams e