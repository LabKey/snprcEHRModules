USE [animal]
GO

CREATE VIEW [labkey_etl].[v_delete_valid_diet] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 03/05/2019
-- Description:	Selects the valid_diet for LabKey snprc_ehr.valid_diet dataset for deletions
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT avd.object_id,
       avd.audit_date_tm


FROM audit.audit_valid_diet AS avd

WHERE avd.audit_action = 'D' AND avd.object_id IS NOT NULL



  GO


GRANT SELECT on labkey_etl.v_delete_valid_diet to z_labkey
GRANT SELECT ON audit.audit_valid_diet TO z_labkey

  go