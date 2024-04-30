USE [animal];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO


ALTER VIEW labkey_etl.v_Sqlmed_obr
AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 7-7-2022
-- Description:	Selects the OBR records from Sqlmed data to populate LabKey HL7 tables
-- ==========================================================================================
SELECT obr.MESSAGE_ID AS MESSAGE_ID,
	   COALESCE (obr.MESSAGE_CONTROL_ID, '0') AS MESSAGE_CONTROL_ID,
	   1 AS IDX,
	   LTRIM(RTRIM(obr.ANIMAL_ID)) AS ANIMAL_ID,
	   --obr.VERIFIED_DATE_TM AS VERIFIED_DATE_TM,
	   obr.REQUESTED_DATE_TM AS REQUESTED_DATE_TM,
       obr.OBSERVATION_DATE_TM AS OBSERVATION_DATE_TM,
	   obr.SPECIMEN_RECEIVED_DATE_TM AS SPECIMEN_RECEIVED_DATE_TM,
       CAST(CAST(obr.VERIFIED_DATE_TM AS DATETIME2(0)) AS DATETIME) AS VERIFIED_DATE_TM,
       obr.PV1_VISIT_NUM AS PV1_VISIT_NUM,
	   obr.SET_ID AS SET_ID,
       obr.SPECIMEN_NUM AS SPECIMEN_NUM,
       obr.PROCEDURE_ID AS PROCEDURE_ID,
       lu.ServiceName AS PROCEDURE_NAME,
	   obr.PRIORITY AS PRIORITY,
	   obr.RESULT_STATUS AS RESULT_STATUS,
	   obr.TECHNICIAN_NAME AS TECHNICIAN_FIRST_NAME,
	   obr.TECHNICIAN_INITIALS AS TECHNICIAN_LAST_NAME,
	   obr.CHARGE_ID AS CHARGE_ID,
       obr.OBJECT_ID AS OBJECT_ID,
       dbo.f_map_username(obr.USER_NAME) AS USER_NAME,
       obr.ENTRY_DATE_TM AS ENTRY_DATE_TM,
       obr.TIMESTAMP AS TIMESTAMP
FROM dbo.CLINICAL_PATH_OBR AS obr

    -- select primates only from the TxBiomed colony
    INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.ANIMAL_ID
    INNER JOIN dbo.CLINICAL_PATH_LABWORK_SERVICES AS lu ON obr.PROCEDURE_ID = lu.ServiceId
    LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = obr.OBJECT_ID
WHERE obr.RESULT_STATUS IN ( 'F', 'C', 'D' )
      AND obr.VERIFIED_DATE_TM IS NOT NULL;

GO

GRANT SELECT ON labkey_etl.v_Sqlmed_obr TO z_labkey;
GO
