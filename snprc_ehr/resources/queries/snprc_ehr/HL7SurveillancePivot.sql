select spi.Id,
    spi.date,
    spi.Id || '-' || CAST(spi.date AS VARCHAR) as key,
    spi.PROCEDURE_NAME,
    spi.PROCEDURE_ID,
    spi.COMMENT,
    spi.TestName,
    MAX(spi.ABNORMAL_FLAGS) as ABNORMAL_FLAGS,
    COALESCE(MAX(spi.RESULT), GROUP_CONCAT(spi.QUALITATIVE_RESULT)) as RESULT
from snprc_ehr.HL7SurveillancePivotInner as spi

GROUP BY spi.id, spi.date, spi.PROCEDURE_NAME,  spi.PROCEDURE_NAME, spi.PROCEDURE_ID, spi.COMMENT, spi.TestName
    PIVOT RESULT, ABNORMAL_FLAGS BY TestName

    IN
    (
    select DISTINCT TestName from snprc_ehr.labwork_panels t
    where t.includeInPanel = true AND t.ServiceId.Dataset='Surveillance'
    )
