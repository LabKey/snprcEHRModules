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
select
  Id,
  date,
  enddate,
  type,
  tissue,
  project,
  instructions,
  servicerequested,
  units,
  serviceId,
  collectedBy,
  sampleId,
  collectionMethod,
  method,
  sampleQuantity,
  quantityUnits,
  chargetype,
  verifiedDate,
  datefinalized,
  remark,
  history,
  objectid,
  lsid
from study.clinpathRuns

union

select
  Id,
  date,
  enddate,
  type,
  tissue,
  project,
  instructions,
  servicerequested,
  units,
  serviceId,
  collectedBy,
  sampleId,
  collectionMethod,
  method,
  sampleQuantity,
  quantityUnits,
  chargetype,
  verifiedDate,
  datefinalized,
  remark,
  history,
  sampleId as objectid,
  lsid
from study.assay_clinpathRuns

union

select distinct
    tr.Id,
    tr.date,
    null enddate,
    'surveillance' as type,
    null as tissue,
    null as project,
    null as instructions,
    ls.serviceName,
    null as units,
    20000 as serviceId,
    null as collectedBy,
    null as sampleId,
    null as collectionMethod,
    null as method,
    null as sampleQuantity,
    null as quantityUnits,
    null as chargetype,
    tr.date as verifiedDate,
    tr.date as datefinalized,
    'From Excel import' as remark,
    tr.history as history,
    cast(tr.sequencenum as varchar) as objectid,
    tr.lsid
from study.TaqmanResults as tr
inner join snprc_ehr.labwork_services as ls on ls.serviceId = 20000

