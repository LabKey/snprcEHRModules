-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 7-11-2022
-- Description:	copy NTE records from Sqlmed data to populate LabKey HL7 tables
-- ==========================================================================================
INSERT INTO labkey.snprc_ehr.HL7_NTE
(
    MESSAGE_ID,
    IDX,
    OBR_OBJECT_ID,
    SET_ID,
    OBR_SET_ID,
    COMMENT,
    Container,
    OBJECT_ID,
    USER_NAME,
    ENTRY_DATE_TM
)

(
SELECT nte.MESSAGE_ID AS MESSAGE_ID,
       1 AS IDX,
       obr.OBJECT_ID as OBR_OBJECT_ID,
       nte.SET_ID AS SET_ID,
       obr.SET_ID AS OBR_SET_ID,
       nte.COMMENT as COMMENT,
       c.EntityId as Container,
       nte.OBJECT_ID AS OBJECT_ID,
       dbo.f_map_username(nte.USER_NAME) AS USER_NAME,
       nte.ENTRY_DATE_TM AS ENTRY_DATE_TM
FROM dbo.CLINICAL_PATH_NTE AS nte
    -- select primates only from the TxBiomed colony
    INNER JOIN dbo.CLINICAL_PATH_OBR as obr on nte.MESSAGE_ID = obr.MESSAGE_ID
    INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.ANIMAL_ID
    LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = nte.OBJECT_ID
    INNER JOIN labkey.core.Containers AS c on c.name = 'SNPRC'
WHERE obr.VERIFIED_DATE_TM IS NOT NULL
)
