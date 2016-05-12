USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW labkey_etl.v_labwork_services AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 5/6/2016
-- Description:	selects data for the snprc_ehr.labwork_services lookup table
-- Changes:
--
--
-- ==========================================================================================
SELECT
     pil.procedure_id as [serviceid],
     pil.procedure_name as [servicename],
     pil.procedure_type as [dataset],
     0 as [alertOnComplete],
 	   pil.object_id AS [objectId],
	   pil.ENTRY_DATE_TM AS [entryDateTm],
	   pil.USER_NAME AS [userName]
FROM dbo.CLINICAL_PATH_PROC_ID_LOOKUP AS pil
GO

GRANT SELECT ON labkey_etl.v_labwork_services TO z_labkey
  
GO