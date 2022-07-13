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
   7/13/2022 Refactored to use HL7 tables from Orchard

 */
SELECT
    obr.ANIMAL_ID AS Id,
    obr.OBSERVATION_DATE_TM as date,
    obr.CHARGE_ID as project,
    obr.PROCEDURE_ID as serviceId,
    obx.serviceTestId as serviceTestId,
    obx.TEST_ID as testId,
    NULL as resultOORIndicator,
    obx.VALUE_TYPE as VALUE_TYPE,
    CAST(obx.RESULT as DOUBLE) as RESULT,
    obx.UNITS as units,
    obx.QUALITATIVE_RESULT as qualresult,
    obx.REFERENCE_RANGE as refRange,
    obx.ABNORMAL_FLAGS as abnormal_flags,
    obx.MESSAGE_ID as runId,
    NULL as enddate,
    NULL as method,
    nte.COMMENT as remark
FROM snprc_ehr.HL7_OBR obr
    LEFT OUTER JOIN snprc_ehr.HL7_OBX obx ON obr.OBJECT_ID = obx.OBR_OBJECT_ID AND obr.SET_ID = obx.OBR_SET_ID
    LEFT OUTER JOIN
    (
        select nte.OBR_OBJECT_ID, nte.OBR_SET_ID, GROUP_CONCAT(nte.COMMENT) as COMMENT
        from snprc_ehr.HL7_NTE nte
        group by nte.OBR_OBJECT_ID, nte.OBR_SET_ID

    ) AS nte ON obr.OBJECT_ID = nte.OBR_OBJECT_ID AND obr.SET_ID = nte.OBR_SET_ID
    LEFT OUTER JOIN snprc_ehr.labwork_Panels AS lp on obx.TEST_ID = lp.TestId AND obr.PROCEDURE_ID = lp.ServiceId

UNION
select
  alr.Id,
  alr.date,
  alr.project,
  alr.serviceId,
  alr.serviceTestId,
  alr.testid,
  alr.resultOORIndicator,
  alr.value_type,
  alr.result,
  alr.units,
  alr.qualresult,
  alr.refRange,
  alr.abnormal_flags,
  alr.runid,
  alr.enddate,
  alr.method,
  alr.remark
from study.assay_labworkResults as alr
union

select
    lt.Id,
    lt.date,
    lt.project,
    lt.serviceId,
    lt.serviceTestId,
    lt.testid,
    lt.resultOORIndicator,
    lt.value_type,
    lt.result,
    lt.units,
    lt.qualresult,
    lt.refRange,
    lt.abnormal_flags,
    lt.runid,
    lt.enddate,
    lt.method,
    remark
from study.labworkTaqman as lt
