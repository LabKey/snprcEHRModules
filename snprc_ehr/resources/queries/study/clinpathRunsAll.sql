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
    ANIMAL_ID as Id,
    OBSERVATION_DATE_TM AS date,
    NULL AS enddate,
    PROCEDURE_ID.Dataset.ServiceType AS type,
    NULL as tissue,
    CHARGE_ID AS project,
    NULL AS instructions,
    PROCEDURE_ID.ServiceName AS servicerequested,
    NULL AS units,
    PROCEDURE_ID AS serviceId,
    NULL AS collectedBy,
    SPECIMEN_NUM AS sampleId,
    NULL AS collectionMethod,
    NULL AS method,
    NULL AS sampleQuantity,
    NULL AS quantityUnits,
    NULL AS chargetype,
    VERIFIED_DATE_TM AS verifiedDate,
    NULL AS datefinalized,
    NULL AS remark,
    NULL AS history,
    OBJECT_ID AS objectid,
    NULL AS lsid
from snprc_ehr.HL7_OBR

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
  objectid,
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
    null as objectid,
    tr.lsid
from study.TaqmanResults as tr
inner join snprc_ehr.labwork_services as ls on ls.serviceId = 20000

