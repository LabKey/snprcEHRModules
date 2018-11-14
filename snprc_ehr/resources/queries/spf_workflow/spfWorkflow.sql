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
  Purpose: ETL from SPF assay tables to clinpathRuns
  Author: Charles Peterson, Texas Biomedical Research Institute, September 20, 2018
 */
  select distinct
    d.snprc_id as Id,
    d.sample_date as date,
    d.report_date as datefinalized,
    d.procedure_id as serviceId,
    d.report_date as verifiedDate,
    d.procedure_id as servicerequested,
    'Surveillance' as type,
    d.file_name as remark,
    d.sample as sampleId

  from spf_workflow.data as d
