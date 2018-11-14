/*
 * Copyright (c) 2018 LabKey Corporation
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
  age.label,
  age.species,
  age.ageclass,

  -- please excuse the ugly formatting - A sql server convert function would be helpful here!
  case when (age."max" is NULL and age.label = 'Senior') then
    (CAST(age."min" as VARCHAR(5) ) + case when (age."min"- truncate(age."min", 0) > 0)  then  '' else '.0 - ' end)
  ELSE
    (CAST(age."min" as VARCHAR(5)) +
     + case when (age."min"- truncate(age."min", 0) > 0)  then  ' - ' else '.0 - ' end

     + CAST(age."max" as varchar(5))
     + case when (age."max"- truncate(age."max", 0) > 0)  then  '' else '.0' end )
  END AS ageRange,

  age.gender

FROM ehr_lookups.AgeclassesAll AS age

