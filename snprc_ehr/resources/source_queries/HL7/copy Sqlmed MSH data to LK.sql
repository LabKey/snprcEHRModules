-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 7-11-2022
-- Description:	Copy MSH records from Sqlmed data to populate LabKey HL7 tables
-- Changes:
-- 02/28/2023: Retargeted query to use linked server and added a cutoff date
-- ==========================================================================================
BEGIN TRAN 
DECLARE @obr_date DATE
SET @obr_date = '02/28/2023'

INSERT INTO labkey.snprc_ehr.HL7_MSH
(
    MESSAGE_ID,
    IDX,
    SENDING_APPLICATION,
    SENDING_FACILITY,
    RECEIVING_APPLICATION,
    RECEIVING_FACILITY,
    MESSAGE_TYPE,
    TRIGGER_EVENT_ID,
    MESSAGE_CONTROL_ID,
    MESSAGE_DATE_TM,
    OBJECT_ID,
    USER_NAME,
    ENTRY_DATE_TM,
	Container
)
(
	SELECT obr.MESSAGE_ID AS MESSAGE_ID,
		   0 AS IDX,
		   'Sqlmed' AS SENDING_APPLICATION,
		   'TxBiomed' AS SENDING_FACILITY,
		   'TAC' AS RECEIVING_APPLICATION,
		   'TxBiomed' AS RECEIVING_FACILITY,
		   'ORU' AS MESSAGE_TYPE,
		   '' AS TRIGGER_EVENT_ID,
		   obr.MESSAGE_CONTROL_ID AS MESSAGE_CONTROL_ID,
		   CAST(CAST(obr.VERIFIED_DATE_TM AS DATETIME2(0)) AS DATETIME) AS MESSAGE_DATE_TM,
		   obr.OBJECT_ID AS OBJECT_ID,
		   animal.dbo.f_map_username(obr.USER_NAME) AS USER_NAME,
		   obr.ENTRY_DATE_TM AS ENTRY_DATE_TM,
		   c.EntityId AS container
	FROM [FROGSTAR\VORTEX].animal.dbo.CLINICAL_PATH_OBR AS obr

		-- select primates only from the TxBiomed colony
		INNER JOIN [FROGSTAR\VORTEX].[animal].labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.ANIMAL_ID
		LEFT OUTER JOIN [FROGSTAR\VORTEX].[animal].dbo.TAC_COLUMNS AS tc ON tc.object_id = obr.OBJECT_ID
		INNER JOIN labkey.core.Containers AS c ON c.Name = 'SNPRC'
	WHERE obr.RESULT_STATUS IN ( 'F', 'C', 'D' )
		  AND obr.VERIFIED_DATE_TM IS NOT NULL
		  AND NOT EXISTS (SELECT 1 FROM [FROGSTAR\VORTEX].animal.labkey_etl.v_delete_clinPathRuns AS dcpr WHERE obr.OBJECT_ID = dcpr.objectid)

	AND obr.MESSAGE_ID IN (
		SELECT MESSAGE_ID FROM [FROGSTAR\VORTEX].animal.dbo.CLINICAL_PATH_OBR
		WHERE CAST(ENTRY_DATE_TM AS DATE) = @obr_date
	)

)
--COMMIT
