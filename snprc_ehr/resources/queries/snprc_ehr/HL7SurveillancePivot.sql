select Id,
    date,
    PROCEDURE_NAME,
    PROCEDURE_ID,
    COMMENT,
    TestName,
    MAX(ABNORMAL_FLAGS) as ABNORMAL_FLAGS,
    COALESCE(MAX(RESULT), MAX(QUALITATIVE_RESULT)) as RESULT
from snprc_ehr.HL7SurveillancePivotInner

GROUP BY id, date, PROCEDURE_NAME,  PROCEDURE_NAME, PROCEDURE_ID, COMMENT, TestName
    PIVOT RESULT, ABNORMAL_FLAGS BY TestName

    IN
    (
    select TestName from snprc_ehr.labwork_panels t
    where t.includeInPanel = true AND t.ServiceId.Dataset='Surveillance'
    )
