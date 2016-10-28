/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
  i1.Id,
  group_concat(DISTINCT i1.id_value) as idHistoryList

FROM (
SELECT
  i.Id,
  concat(concat( i.value, '/') ,i.id_type.description) as id_value

FROM study.idHistory i
where i.id_type.value not in ( 1, 30)


) i1

GROUP BY i1.Id