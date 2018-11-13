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

SELECT

a.animal_id AS Id,
COALESCE(a.biopsy, a.death) AS date,
a.accession_num AS caseno,
a.object_id AS objectid,
a.user_name AS performedby,
a.timestamp,

CASE
WHEN d.description LIKE 'Pending%' THEN 'Review Required'
ELSE 'Completed'
END AS QCStateLabel,

CASE
WHEN a.tissue IS NOT NULL THEN (a.tissue + '-' + b.description)
ELSE b.description
END AS title

FROM snprcApath.apath a INNER JOIN snprcApath.valid_accession_codes b ON a.accession_code = b.accession_code
INNER JOIN snprcApath.valid_record_status d ON a.record_status = d.record_status

WHERE a.animal_id IS NOT NULL AND COALESCE(a.biopsy, a.death) IS NOT NULL AND b.description IS NOT NULL