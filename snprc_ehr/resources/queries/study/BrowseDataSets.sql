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
  select 'study' as schema, 'ClinPath' as CategoryId,'Surveillance Results' as Label, 'surveillancePivot' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'study' as schema, 'ClinPath' as CategoryId,'Hematology Results' as Label, 'hematologyPivot' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'study' as schema, 'ClinPath' as CategoryId,'Biochemistry Results' as Label, 'chemPivot' as Name,  true as ShowByDefault, true as isAnimal
UNION
select 'study' as schema, 'ClinPath' as CategoryId,'Misc Lab Results' as Label, 'miscPivot' as Name,  true as ShowByDefault, true as isAnimal
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
select 'study' as schema, 'Clinical' as CategoryId,'Daily Observations' as Label, 'dailyObsPivot' as Name,  true as ShowByDefault, true as isAnimal