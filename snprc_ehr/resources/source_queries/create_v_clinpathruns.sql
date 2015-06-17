USE [animal]
GO

/****** Object:  View [dbo].[Labkey_etl.v_clinPathRuns]    Script Date: 1/8/2015 4:02:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER  VIEW Labkey_etl.v_clinPathRuns AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 1/08/2015
-- Description:	Selects the ETL records for LabKey study.clinPathRuns dataset 
-- Note:  Currently only selecting the following data types:
--			Hematology, Biochemistry, Surveillance
-- Changes:
--
--
-- ==========================================================================================
SELECT obr.animal_id AS [Id],
	   obr.OBSERVATION_DATE_TM AS [Date],
	   obr.message_id AS [objectId],
	   obr.verified_date_tm as [dateFinalized],
	   obr.SPECIMEN_NUM AS [sampleId], 
	   obr.PROCEDURE_NAME AS [serviceRequested],
	   obr.PV1_VISIT_NUM AS [animalVisit],
	   obr.ENTRY_DATE_TM AS [created],
	   obr.USER_NAME AS [createdBy]
FROM dbo.CLINICAL_PATH_OBR AS obr
JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.ANIMAL_ID
WHERE obr.PROCEDURE_ID IN (SELECT obr.PROCEDURE_ID FROM clinical_path_proc_id_lookup)
--WHERE (obr.PROCEDURE_NAME LIKE '%differential only%' 
--   OR obr.PROCEDURE_NAME LIKE '%CBC%' 
--   OR  obr.PROCEDURE_id IN (10200, 10201, 106262) )
  AND obr.RESULT_STATUS = 'F'
  AND obr.VERIFIED_DATE_TM IS NOT NULL
--  AND obr.VERIFIED_DATE_TM >= '1/1/2014 00:00'

GO



GRANT SELECT ON Labkey_etl.v_clinPathRuns TO z_camp_base
GRANT SELECT ON Labkey_etl.v_clinPathRuns TO z_labkey
  
GO