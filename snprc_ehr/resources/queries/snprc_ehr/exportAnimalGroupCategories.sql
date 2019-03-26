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
  c.category_code as category_code,
  c.description as description,
  c.comment as comment,
  c.displayable as displayable,
  c.species as species,
  c.sex as sex,
  c.enforce_exclusivity as enforce_exclusivity,
  c.allow_future_date as allow_future_date,
  c.sort_order as sort_order,
  c.modified as entry_date_tm,
  c.modifiedby.displayName as user_name,
  c.objectId as object_id
FROM snprc_ehr.animal_group_categories as c