/*
 * Copyright (c) 2019 LabKey Corporation
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
  g.code as code,
  g.category_code as category_code,
  g.date as start_date,
  g.enddate as end_date,
  g.name as description,
  g.comment as comment,
  g.sort_order as sort_order,
  g.modified as entry_date_tm,
  g.modifiedby.displayName as user_name,
  g.objectId as object_id
FROM snprc_ehr.animal_groups as g