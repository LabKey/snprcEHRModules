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
  pc.id,
  pc.id.demographics.gender as gender,
  --d.gender as gender,
  pc.id.demographics.species.arc_species_code.code as species,
  pc.id.demographics.birth as birth,
  pc.Id.Age.yearsAndMonths as age,
  pc.date,
  pc.AccessionCode,
  pc.AccessionNumber,
  pd.morphology,
  pd.organ,
  pd.etiology_code,
  pd.sp_etiology
FROM study.PathologyCases AS pc
  LEFT JOIN study.PathologyDiagnoses AS pd ON pc.AccessionNumber = pd.AccessionNumber
--INNER JOIN study.demographics AS d ON d.id = pc.id
--WHERE pc.qcstate.publicdata = TRUE