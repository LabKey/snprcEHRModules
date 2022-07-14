-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 7-11-2022
-- Description:	Copy MSH records from Sqlmed data to populate LabKey HL7 tables
-- Changes:
-- ==========================================================================================
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
    ENTRY_DATE_TM
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
		   obr.VERIFIED_DATE_TM AS MESSAGE_DATE_TM,
		   obr.OBJECT_ID AS OBJECT_ID,
		   dbo.f_map_username(obr.USER_NAME) AS USER_NAME,
		   obr.ENTRY_DATE_TM AS ENTRY_DATE_TM
	FROM dbo.CLINICAL_PATH_OBR AS obr

		-- select primates only from the TxBiomed colony
		INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.ANIMAL_ID
		LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = obr.OBJECT_ID
	WHERE obr.RESULT_STATUS IN ( 'F', 'C', 'D' )
		  AND obr.VERIFIED_DATE_TM IS NOT NULL
		  AND NOT EXISTS (SELECT 1 FROM labkey_etl.v_delete_clinPathRuns AS dcpr WHERE obr.OBJECT_ID = dcpr.objectid)
)