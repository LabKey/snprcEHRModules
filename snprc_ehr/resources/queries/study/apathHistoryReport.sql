/*
 * Copyright (c) 2017-2018 LabKey Corporation
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
  pc.id,
  pc.id.demographics.gender as gender,
  pc.id.demographics.species.arc_species_code.code as species,
  pc.id.demographics.birth as birth,
 ROUND(CONVERT(age_in_months(pc.id.demographics.birth, pc.date), DOUBLE) / 12, 1) as ageAtTime,
  ac.label as ageClass,
  pc.date,
  pc.AccessionCode,
  pc.AccessionNumber,
  pc.deathType,
  pd.morphology,
  pd.organ,
  pd.etiology_code,
  pd.sp_etiology
FROM study.PathologyCases AS pc
LEFT JOIN study.PathologyDiagnoses AS pd ON pc.AccessionNumber = pd.AccessionNumber
LEFT JOIN ehr_lookups.ageclass ac
    ON (
        (CONVERT(age_in_months(pc.id.demographics.birth, pc.date), DOUBLE) / 12) >= ac."min" AND
        ((CONVERT(age_in_months(pc.id.demographics.birth, pc.date), DOUBLE) / 12) < ac."max" OR ac."max" is null) AND
        pc.id.demographics.species.arc_species_code.code = ac.species AND
        (pc.id.demographics.gender = ac.gender OR ac.gender IS NULL)
    )