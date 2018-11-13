/*
 * Copyright (c) 2017 LabKey Corporation
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
a.id as id,
a.protocol as protocol,
case when a.date >= p.startdate then a.date else p.startdate end as assignment_date,
p.project as project,
p.shortname,
--case when COALESCE (a.enddate, p.enddate) is NULL then true else false end  as isActive
a.isActive



FROM study.assignment as a
inner join ehr.project as p on a.protocol = p.protocol