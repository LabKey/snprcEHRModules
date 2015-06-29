USE [animal]
GO

/****** Object:  View [dbo].[Labkey_etl.v_delete_clinPathRuns]    Script Date: 6/26/2015 2:02:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW Labkey_etl.v_delete_clinPathRuns AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/26/2015
-- Description:	Selects the ETL records for LabKey study.clinPathRuns dataset for deletes
-- Changes:
--
--
-- ==========================================================================================
SELECT log.MESSAGE_ID,
log.ENTRY_DATE_TM

FROM dbo.HL7_IMPORT_LOG AS log
WHERE log.RESULT_STATUS = 'X'
  

GO

GRANT SELECT ON Labkey_etl.v_delete_clinPathRuns TO z_labkey
GRANT SELECT ON dbo.HL7_IMPORT_LOG TO z_labkey
  
GO