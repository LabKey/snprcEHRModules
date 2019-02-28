/**************************************

srr
****************************************/
USE [animal]
GO

/****** Object:  View [labkey_etl].[v_delete_location_temperature]    ******/
SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO




ALTER VIEW [labkey_etl].[v_delete_location_temperature] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 02/13/2019
-- Description:	Selects location_temperature for LabKey dataset for deletions
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT al.object_id,
       al.audit_date_tm
FROM audit.audit_location_temperature AS al
	WHERE al.audit_action = 'D' AND al.object_id IS NOT NULL

  GO


GRANT SELECT on labkey_etl.v_delete_location_temperature to z_labkey
GRANT SELECT ON audit.audit_valid_vet TO z_labkey
