-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 7-11-2022
-- Description:	copy NTE records from Sqlmed data to populate LabKey HL7 tables
-- 02/28/2023: Retargeted query to use linked server and added a cutoff date
-- ==========================================================================================
BEGIN TRAN 
DECLARE @obr_date DATE
SET @obr_date = '02/28/2023'

INSERT INTO labkey.snprc_ehr.HL7_NTE
(
    MESSAGE_ID,
    IDX,
    OBR_OBJECT_ID,
    SET_ID,
    OBR_SET_ID,
    COMMENT,
    OBJECT_ID,
    USER_NAME,
    ENTRY_DATE_TM,
	container
)

(
SELECT nte.MESSAGE_ID AS MESSAGE_ID,
       1 AS IDX,
       obr.OBJECT_ID AS OBR_OBJECT_ID,
       nte.SET_ID AS SET_ID,
       obr.SET_ID AS OBR_SET_ID,
       nte.COMMENT AS COMMENT,
       nte.OBJECT_ID AS OBJECT_ID,
       animal.dbo.f_map_username(nte.USER_NAME) AS USER_NAME,
       nte.ENTRY_DATE_TM AS ENTRY_DATE_TM,
	   c.EntityId AS container
FROM [FROGSTAR\VORTEX].animal.dbo.CLINICAL_PATH_NTE AS nte
    -- select primates only from the TxBiomed colony
	INNER JOIN labkey.snprc_ehr.HL7_OBR AS obr ON obr.MESSAGE_ID = nte.MESSAGE_ID
	INNER JOIN labkey.core.Containers AS c ON c.Name = 'SNPRC'

WHERE nte.MESSAGE_ID IN (
	SELECT DISTINCT MESSAGE_ID FROM [FROGSTAR\VORTEX].animal.dbo.CLINICAL_PATH_NTE
	WHERE CAST(ENTRY_DATE_TM AS DATE) = @obr_date
	)
)
--commit