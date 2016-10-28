/*
 * Copyright (c) 2016 LabKey Corporation
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
select i.id as AnimalId,
       i.date as date,
       i.value as id_value,
       i.id_type.description as id_type,
       i.source_name as source,
       i.objectid,
       i.modified
from study.idHistory as i
inner join study.demographics as d on i.id = d.id and d.species.arc_species_code = 'CJ'