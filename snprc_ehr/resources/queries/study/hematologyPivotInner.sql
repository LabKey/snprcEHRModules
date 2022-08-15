/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
    b.id,
    b.date,
    b.runId.serviceRequested as panelName,
    b.serviceTestId.testName AS TestName,
    b.remark,
    COALESCE(CAST(CAST(b.result AS float) AS VARCHAR), b.qualresult) as result,
    b.abnormal_flags

FROM study.labworkResults b
WHERE b.serviceTestId.includeInPanel = true and b.serviceTestid.ServiceId.Dataset = 'Hematology'

UNION

SELECT
    obr.ANIMAL_ID as id,
    obr.OBSERVATION_DATE_TM as date,
    COALESCE (lp.ServiceId.ServiceName, obr.PROCEDURE_NAME) as PanelName,
    COALESCE (lp.TestName, obx.TEST_NAME) as TestName,
    nte.COMMENT as remark,
    COALESCE(obx.RESULT, obx.QUALITATIVE_RESULT) as result,
    obx.ABNORMAL_FLAGS as abnormal_flags
FROM snprc_ehr.HL7_OBR obr
    LEFT OUTER JOIN snprc_ehr.HL7_OBX obx ON obr.OBJECT_ID = obx.OBR_OBJECT_ID AND obr.SET_ID = obx.OBR_SET_ID
    LEFT OUTER JOIN snprc_ehr.labwork_Panels AS lp on obx.TEST_ID = lp.TestId AND obr.PROCEDURE_ID = lp.ServiceId
    LEFT OUTER JOIN snprc_ehr.HL7_GroupNTE AS nte ON obr.OBJECT_ID = nte.OBR_OBJECT_ID AND obr.SET_ID = nte.OBR_SET_ID
WHERE obr.PROCEDURE_ID.Dataset = 'Hematology'
