/*
 * Copyright (c) 2015-2018 LabKey Corporation
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
SELECT DISTINCT
  a.demographics.id As Animal,
  a.demographics.gender As Gender,
  a.ageclass.label As "AgeClass",
  h.room,
  hr.roommateId.id As Roommate,
  rd.demographics.gender As "Roommate Gender",
  rd.ageclass.label As "Roommate Age Class"

FROM study.Animal a

LEFT JOIN study.housing h
ON (a.id=h.id)

LEFT JOIN study.housingRoommates hr
ON (a.id=hr.id)

LEFT JOIN study.Animal rd
ON (rd.id=hr.roommateId.id)
