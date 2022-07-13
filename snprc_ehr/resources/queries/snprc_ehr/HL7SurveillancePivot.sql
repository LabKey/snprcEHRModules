/* Valid Service types:
	Biochemistry
	Culture
	Hematology
	Histology
	Misc Tests
	Parasitology
	Surveillance
	Unknown
	Urinalysis
 */
 select Id,
    date,
    MESSAGE_ID,
    PROCEDURE_NAME,
    PROCEDURE_ID,
    COMMENT,
    TestName,
    MAX(ABNORMAL_FLAGS) as ABNORMAL_FLAGS,
    MAX(QUALITATIVE_RESULT) as QUALITATIVE_RESULT,
    MAX(RESULT) as RESULT
from snprc_ehr.HL7SurveillancePivotInner

GROUP BY id, date, MESSAGE_ID, PROCEDURE_NAME,  PROCEDURE_NAME, PROCEDURE_ID, COMMENT, TestName
    PIVOT RESULT, QUALITATIVE_RESULT, ABNORMAL_FLAGS BY TestName

     IN
    (
    select TestName from snprc_ehr.labwork_panels t
    where t.includeInPanel = true AND t.ServiceId.Dataset='Surveillance'
    )

