/*
 * Copyright (c) 2018-2019 LabKey Corporation
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
select 'study' as Schema,
    categoryId.label as CategoryId,
    Label as Label,
    Name as name,
    ShowByDefault as ShowByDefault,
true as isAnimal
from study.datasets
UNION
  select 'study' as schema, 'ClinPath' as CategoryId,'Clinpath Runs' as Label, 'clinpathRunsAll' as Name,  true as ShowByDefault, true as isAnimal
UNION
  select 'snprc_ehr' as schema, 'ClinPath' as CategoryId,'Surveillance Results' as Label, 'Hl7SurveillancePivot' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'snprc_ehr' as schema, 'ClinPath' as CategoryId,'Hematology Results' as Label, 'HL7HematologyPivot' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'snprc_ehr' as schema, 'ClinPath' as CategoryId,'Biochemistry Results' as Label, 'HL7BiochemistryPivot' as Name,  true as ShowByDefault, true as isAnimalisAnimal
UNION
select 'snprc_ehr' as schema, 'ClinPath' as CategoryId,'Culture and susceptibility Results' as Label, 'HL7CulturePivot' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'snprc_ehr' as schema, 'ClinPath' as CategoryId,'Misc Lab Results' as Label, 'HL7MiscPivot' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'study' as schema, 'ClinPath' as CategoryId,'SNPRC Labwork Results' as Label, 'labworkResultsAll' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'snprc_ehr' as schema, 'Misc' as CategoryId,'Fee Schedule' as Label, 'FeeSchedulePivot' as Name,  true as ShowByDefault, false as isAnimal
UNION
select 'ehr_lookups' as schema, 'Lookup Tables' as CategoryId,'Lookup sets' as Label, 'lookup_sets' as Name,  true as ShowByDefault, false as isAnimal
UNION
select 'snprc_ehr' as schema, 'Misc' as CategoryId,'Valid Charge by Species' as Label, 'ValidChargeBySpecies' as Name,  true as ShowByDefault, false as isAnimal
UNION
select 'study' as schema, 'Colony Management' as CategoryId,'Animal Accounts & Groups' as Label, 'ActiveAccountsWithGroup' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'snprc_ehr' as schema, 'Misc' as CategoryId,'MHC Data' as Label, 'MhcData' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'snprc_ehr' as schema, 'Misc' as CategoryId,'MHC Pivot' as Label, 'MhcDataPivot' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'study' as schema, 'Clinical' as CategoryId,'Daily Observations' as Label, 'DailyObs' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'study' as schema, 'Clinical' as CategoryId,'Daily Cycles' as Label, 'CycleDaily' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'study' as schema, 'Clinical' as CategoryId,'Vaccine' as Label, 'Vaccine' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'study' as schema, 'Clinical' as CategoryId,'Blood Type' as Label, 'BloodType' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'snprc_ehr' as schema, 'ClinPath' as CategoryId,'Parasitology' as Label, 'HL7ParasitologyPivot' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'snprc_ehr' as schema, 'Misc' as CategoryId,'Location Temperature' as Label, 'LocationTemperature' as Name,  true as ShowByDefault, false as isAnimal
UNION
select 'study' as schema, 'Misc' as CategoryId,'Animals with Genetic data' as Label, 'GenDemohasData' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'study' as schema, 'Behavior' as CategoryId,'Abnormal Behavior' as Label, 'BehaviorAbnormalAll' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'study' as schema, 'Clinical' as CategoryId,'Body Condition Scores' as Label, 'BodyConditionScores' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'snprc_ehr' as schema, 'ClinPath' as CategoryId,'Urinalysis Results' as Label, 'HL7UrinalysisPivot' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'ehr' as schema, 'Colony Management' as CategoryId,'Kinship' as Label, 'kinship' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'ehr' as schema, 'Colony Management' as CategoryId,'Project' as Label, 'project' as Name,  true as ShowByDefault, false as isAnimal
