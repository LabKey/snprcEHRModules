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

a.animal_id as Id,
coalesce(a.biopsy, a.death) as date,
a.accession_num as caseno,
a.object_id as objectid,
a.timestamp,

CASE
WHEN a.tissue is not null THEN (a.tissue + '-' + b.description)
ELSE b.description
END AS title

from snprcApath.apath a inner join snprcApath.valid_accession_codes b on a.accession_code = b.accession_code

where a.animal_id is not null and coalesce(a.biopsy, a.death) is not null and b.description is not null