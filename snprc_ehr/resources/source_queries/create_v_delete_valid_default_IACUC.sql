USE [animal]
GO

CREATE VIEW [labkey_etl].[v_delete_valid_default_IACUC] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 05/06/2020
-- Description:	Selects the valid default IACUC dataset for deletions
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT avd.object_id,
       avd.audit_date_tm

FROM audit.audit_valid_default_iacuc AS avd
WHERE avd.audit_action = 'D' AND avd.object_id IS NOT NULL;
GO


GRANT SELECT on labkey_etl.v_delete_valid_default_IACUC to z_labkey;
GRANT SELECT ON audit.audit_valid_default_iacuc TO z_labkey;
GO