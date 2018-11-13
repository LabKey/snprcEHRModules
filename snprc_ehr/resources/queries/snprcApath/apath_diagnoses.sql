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

a.unique_it AS Id,
COALESCE (b.biopsy, b.death) AS date,
a.object_id AS objectid,
b.object_id AS parentid,
a.user_name AS performedby,
a.morphology,
a.organ,
a.etiology_code,
a.sp_etiology,
a.timestamp,

FROM snprcApath.diagnosis a INNER JOIN snprcApath.apath b ON a.accession_num = b.accession_num

WHERE a.unique_it IS NOT NULL AND COALESCE(b.biopsy, b.death) IS NOT NULL