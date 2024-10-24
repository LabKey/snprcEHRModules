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
SELECT
    cpr.Id,
    cpr.date,
    cpr.enddate,
    COALESCE(cpr.serviceId.Dataset.ServiceType, cpr.type) as type,
    cpr.tissue,
    cpr.project,
    cpr.instructions,
    cpr.servicerequested,
    cpr.units,
    cpr.serviceId,
    cpr.collectedBy,
    cpr.sampleId,
    cpr.collectionMethod,
    cpr.method,
    cpr.sampleQuantity,
    cpr.quantityUnits,
    cpr.chargetype,
    cpr.verifiedDate,
    cpr.datefinalized,
    lr.remark as remark,
    cpr.history,
    cpr.objectid,
    cpr.lsid,
    cpr.QCState
FROM study.clinpathRuns cpr
         LEFT JOIN study.labworkResults lr on lr.runId = cpr.objectId and lr.remark is not null
UNION

select
    obr.ANIMAL_ID as Id,
    obr.OBSERVATION_DATE_TM AS date,
    NULL AS enddate,
    obr.PROCEDURE_ID.Dataset.ServiceType AS type,
    NULL as tissue,
    obr.CHARGE_ID AS project,
    NULL AS instructions,
    obr.PROCEDURE_ID.ServiceName AS servicerequested,
    NULL AS units,
    obr.PROCEDURE_ID AS serviceId,
    NULL AS collectedBy,
    obr.SPECIMEN_NUM AS sampleId,
    NULL AS collectionMethod,
    NULL AS method,
    NULL AS sampleQuantity,
    NULL AS quantityUnits,
    NULL AS chargetype,
    obr.VERIFIED_DATE_TM AS verifiedDate,
    NULL AS datefinalized,
    nte.comment AS remark,
    NULL AS history,
    obr.OBJECT_ID AS objectid,
    NULL AS lsid,
    q.rowId as QCState
FROM snprc_ehr.HL7_OBR as obr
LEFT OUTER JOIN snprc_ehr.HL7_GroupNTE AS nte ON obr.OBJECT_ID = nte.OBR_OBJECT_ID AND obr.SET_ID = nte.OBR_SET_ID
INNER JOIN core.QCState as q on q.Label = 'Completed'

UNION

SELECT
  Id,
  date,
  enddate,
  serviceId.Dataset.ServiceType as type,
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
  lsid,
  QCState
FROM study.assay_clinpathRuns

UNION

SELECT DISTINCT
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
    tr.objectid as objectid,
    tr.lsid,
    tr.QCState
from study.TaqmanResults as tr
inner join snprc_ehr.labwork_services as ls on ls.serviceId = 20000

