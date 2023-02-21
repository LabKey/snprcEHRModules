
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 7-11-2022
-- Description:	copies OBR records from Sqlmed data to populate LabKey HL7 tables
-- ==========================================================================================
BEGIN TRAN
INSERT INTO labkey.snprc_ehr.HL7_OBR
(
    MESSAGE_ID,
    MESSAGE_CONTROL_ID,
    IDX,
    ANIMAL_ID,
    VERIFIED_DATE_TM,
    REQUESTED_DATE_TM,
    OBSERVATION_DATE_TM,
    SPECIMEN_RECEIVED_DATE_TM,
    PV1_VISIT_NUM,
    SET_ID,
    SPECIMEN_NUM,
    PROCEDURE_ID,
    PROCEDURE_NAME,
    PRIORITY,
    RESULT_STATUS,
    TECHNICIAN_FIRST_NAME,
    TECHNICIAN_LAST_NAME,
    CHARGE_ID,
    OBJECT_ID,
    USER_NAME,
    ENTRY_DATE_TM,
	container
)

(
SELECT obr.MESSAGE_ID AS MESSAGE_ID,
	   COALESCE (obr.MESSAGE_CONTROL_ID, '0') AS MESSAGE_CONTROL_ID,
	   1 AS IDX,
	   LTRIM(RTRIM(obr.ANIMAL_ID)) AS ANIMAL_ID,
	   obr.VERIFIED_DATE_TM AS VERIFIED_DATE_TM,
	   obr.REQUESTED_DATE_TM AS REQUESTED_DATE_TM,
       obr.OBSERVATION_DATE_TM AS OBSERVATION_DATE_TM,
	   obr.SPECIMEN_RECEIVED_DATE_TM AS SPECIMEN_RECEIVED_DATE_TM,
       obr.PV1_VISIT_NUM AS PV1_VISIT_NUM,
	   obr.SET_ID AS SET_ID,
       obr.SPECIMEN_NUM AS SPECIMEN_NUM,
       obr.PROCEDURE_ID AS PROCEDURE_ID,
       COALESCE (lu.ServiceName, obr.PROCEDURE_NAME) AS PROCEDURE_NAME,
	   obr.PRIORITY AS PRIORITY,
	   obr.RESULT_STATUS AS RESULT_STATUS,
	   LEFT(obr.TECHNICIAN_NAME, 50) AS TECHNICIAN_FIRST_NAME,
	   obr.TECHNICIAN_INITIALS AS TECHNICIAN_LAST_NAME,
	   obr.CHARGE_ID AS CHARGE_ID,
       obr.OBJECT_ID AS OBJECT_ID,
       animal.dbo.f_map_username(obr.USER_NAME) AS USER_NAME,
       obr.ENTRY_DATE_TM AS ENTRY_DATE_TM,
	   c.EntityId AS container
FROM animal.dbo.CLINICAL_PATH_OBR AS obr

    -- select primates only from the TxBiomed colony
    INNER JOIN animal.labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.ANIMAL_ID
    INNER JOIN animal.dbo.CLINICAL_PATH_LABWORK_SERVICES AS lu ON obr.PROCEDURE_ID = lu.ServiceId
	INNER JOIN labkey.core.Containers AS c ON c.Name = 'SNPRC'
WHERE obr.RESULT_STATUS IN ( 'F', 'C', 'D' )
    AND obr.VERIFIED_DATE_TM IS NOT NULL
	AND NOT EXISTS (SELECT 1 FROM animal.labkey_etl.v_delete_clinPathRuns AS dcpr WHERE obr.OBJECT_ID = dcpr.objectid)

)
commit