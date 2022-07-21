    SELECT
        obr.ANIMAL_ID AS Id,
        obr.OBSERVATION_DATE_TM as date,
        obr.MESSAGE_ID,
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
    LEFT OUTER JOIN snprc_ehr.labwork_Panels AS lp on obx.TEST_ID = lp.TestId AND obr.PROCEDURE_ID = lp.ServiceId
    WHERE obr.PROCEDURE_ID.Dataset = 'Surveillance'

    UNION

    SELECT
        b.id,
        b.date,
        coalesce(b.runId, cast(b.Sequencenum as varchar)) as MESSAGE_ID,
        b.serviceTestId.serviceId.ServiceName AS PROCEDURE_NAME,
        b.serviceTestId.serviceId AS PROCEDURE_ID,
        b.serviceTestId.testName AS TestName,
        b.remark as COMMENT,
        '' AS ABNORMAL_FLAGS,
        b.qualresult as QUALITATIVE_RESULT,
        b.RESULT as RESULT
    FROM study.labworkTaqman b
    WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Surveillance'

    union

    SELECT
        b.id,
        b.date,
        coalesce(b.runId, b.objectid) as MESSAGE_ID,
        b.serviceTestId.serviceId.ServiceName AS PROCEDURE_NAME,
        b.serviceTestId.serviceId AS PROCEDURE_ID,
        b.serviceTestId.testName AS TestName,
        b.remark as COMMENT,
        '' AS ABNORMAL_FLAGS,
        b.qualresult as QUALITATIVE_RESULT,
        NULL as RESULT
    FROM study.assay_labworkResults b
    WHERE b.serviceTestId.includeInPanel = true and b.qcstate.publicdata = true and b.serviceTestid.ServiceId.Dataset = 'Surveillance'