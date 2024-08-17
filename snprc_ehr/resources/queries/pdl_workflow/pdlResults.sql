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
/*
  Purpose: ETL from SPF assay tables to assay_labworkResults and ultimately SurveillancePivot
  Author: Charles Peterson, Texas Biomedical Research Institute, October 17, 2018
 */
select distinct
  COALESCE(d.snprc_id, d.pdl_animal_id) as Id,
  d.sample_date as date,
  d.procedure_name as panelName,
  NULL as serviceTestId,
  d.procedure_id as serviceId,
  d.test_id as testid,
  d.test_name as test_name,
  NULL as runId,
  NULL as result,
  'ST' as value_type,
  d.results as qualresult,
  d.file_name as remark,
  d.sample as sampleId
from pdl_workflow.data as d
