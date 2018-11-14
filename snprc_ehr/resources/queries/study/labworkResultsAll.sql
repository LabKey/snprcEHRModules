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
/* Purpose: Query to create view combining SPF labworkResults assay and labworkResults table,
            superceding original labworkResults table in all uses.

   Author:  Charles Peterson, 10/29/2018

 */


select
  Id,
  date,
  project,
  serviceId,
  serviceTestId,
  testid,
  resultOORIndicator,
  value_type,
  result,
  units,
  qualresult,
  refRange,
  abnormal_flags,
  runid,
  enddate,
  method,
  remark,
  history
from study.labworkResults

union all

select
  Id,
  date,
  project,
  serviceId,
  serviceTestId,
  testid,
  resultOORIndicator,
  value_type,
  result,
  units,
  qualresult,
  refRange,
  abnormal_flags,
  runid,
  enddate,
  method,
  remark,
  history
from study.assay_labworkResults
