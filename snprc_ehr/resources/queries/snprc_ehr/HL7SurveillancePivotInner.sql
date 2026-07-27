/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    obr.ANIMAL_ID AS Id,
    obr.OBSERVATION_DATE_TM as date,
        COALESCE (lp.ServiceId.ServiceName, obr.PROCEDURE_NAME) as PROCEDURE_NAME,
        obr.PROCEDURE_ID,
        COALESCE (lp.TestName, obx.TEST_NAME) as TestName,
        nte.COMMENT,
        obx.ABNORMAL_FLAGS,
        obx.QUALITATIVE_RESULT,
        obx.RESULT

FROM snprc_ehr.HL7_OBR obr
    LEFT OUTER JOIN snprc_ehr.HL7_OBX obx ON obr.OBJECT_ID = obx.OBR_OBJECT_ID AND obr.SET_ID = obx.OBR_SET_ID
    LEFT OUTER JOIN snprc_ehr.HL7_GroupNTE nte ON obr.OBJECT_ID = nte.OBR_OBJECT_ID AND obr.SET_ID = nte.OBR_SET_ID
    LEFT OUTER JOIN snprc_ehr.labwork_Panels AS lp on obx.TEST_ID = lp.TestId AND obr.PROCEDURE_ID = CAST(lp.ServiceId AS VARCHAR)
WHERE obr.PROCEDURE_ID.Dataset = 'Surveillance'

UNION

SELECT
    b.id,
    b.date,
    b.serviceTestId.serviceId.ServiceName AS PROCEDURE_NAME,
    -- HL7_OBR.PROCEDURE_ID is VARCHAR but labwork_services.ServiceId is INT; cast so the UNION types match on Postgres.
    CAST(b.serviceTestId.serviceId AS VARCHAR) AS PROCEDURE_ID,
    b.serviceTestId.testName AS TestName,
    b.remark as COMMENT,
    '' AS ABNORMAL_FLAGS,
    b.qualresult as QUALITATIVE_RESULT,
    -- labworkTaqman.RESULT is DOUBLE but HL7_OBX.RESULT (first UNION branch) is TEXT; cast to VARCHAR so the UNION types match on Postgres.
    CAST(b.RESULT AS VARCHAR) as RESULT
FROM study.labworkTaqman b
WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Surveillance'

union

SELECT
    b.id,
    b.date,
    b.serviceTestId.serviceId.ServiceName AS PROCEDURE_NAME,
    CAST(b.serviceTestId.serviceId AS VARCHAR) AS PROCEDURE_ID,
    b.serviceTestId.testName AS TestName,
    b.remark as COMMENT,
    '' AS ABNORMAL_FLAGS,
    b.qualresult as QUALITATIVE_RESULT,
    CAST(NULL AS VARCHAR) as RESULT
FROM study.assay_labworkResults b
WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Surveillance'