USE [animal];
GO

/****** Object:  View [labkey_etl].[V_CLINPATHRUNS]    Script Date: 7/7/2022 3:09:20 PM ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO



ALTER VIEW [labkey_etl].[v_Sqlmed_msh]
AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 7-7-2022
-- Description:	Selects the  MSH records from Sqlmed data to populate LabKey HL7 tables
-- Changes:
-- ==========================================================================================
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
       obr.ENTRY_DATE_TM AS ENTRY_DATE_TM,
       dbo.f_map_username(obr.USER_NAME) AS USER_NAME,
       obr.TIMESTAMP AS TIMESTAMP
FROM dbo.CLINICAL_PATH_OBR AS obr

    -- select primates only from the TxBiomed colony
    INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.ANIMAL_ID
    LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = obr.OBJECT_ID
WHERE obr.RESULT_STATUS IN ( 'F', 'C', 'D' )
      AND obr.VERIFIED_DATE_TM IS NOT NULL;


GO

-- Table permissions
GRANT SELECT ON [labkey_etl].[v_Sqlmed_msh] TO  z_labkey;

GO