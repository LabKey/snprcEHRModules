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
b.id,
b.start_date as date,
b.end_date as enddate,

--TODO: how do we ensure the order in which these are populated??
(SELECT a.rowid FROM labkey_trunk.ehr.animal_groups a WHERE a.name = CAST(bg.breeding_grp as varchar)) as groupId,
b."user_name" as performedby
from breeding_grp b
left join dbo.valid_breeding_grps bg ON (b.breeding_grp = bg.breeding_grp)

