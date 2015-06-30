USE [animal]
GO

/****** Object:  View [labkey_etl].[v_delete_charge_account]    Script Date: 6/29/2015 2:25:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




Alter VIEW [labkey_etl].[v_delete_charge_account] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/26/2015
-- Description:	Selects the charge_account data for LabKey ehr.project dataset for deletes
-- Note: 
--		
-- Changes:
--
-- ==========================================================================================


SELECT aca.object_id, 
		aca.audit_date_tm
FROM audit.audit_charge_account AS aca
WHERE aca.audit_action = 'D' AND aca.OBJECT_ID IS NOT NULL

GO

GRANT SELECT on labkey_etl.v_delete_charge_account to z_labkey
GRANT SELECT ON audit.audit_charge_account TO z_labkey

go
