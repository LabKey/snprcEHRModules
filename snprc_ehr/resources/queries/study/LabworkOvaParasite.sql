/*
 * Copyright (c) 2019 LabKey Corporation
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
SELECT ServiceId.Dataset,  ServiceId.ServiceName, *
FROM snprc_ehr.labwork_panels
WHERE ServiceId.Dataset='Parasitology' and ServiceId.ServiceName in ('OVA & PARASITES' , 'OVA & PARASITES, URINE' )
SELECT
  l.id,
  l.date,
  l.project,
  l.testid,
  l.resultOORIndicator,
  l.value_type,
  lt.testName,
  l.result,
  l.qualresult,
  l.units,
  l.refRange,
  l.abnormal_flags,
  l.remark,
  l.description,
  l.runid,
  l.taskid,
  l.method,
  l.objectid,
  l.modified,
  l.modifiedby,
  l.created,
  l.createdby
FROM labworkResults as l
       inner join snprc_ehr.labwork_panels as lt
         on l.serviceTestid = lt.rowId and lt.TestId in (77, 201, 727)