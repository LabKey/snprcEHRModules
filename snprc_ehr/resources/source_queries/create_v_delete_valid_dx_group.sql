USE [animal]
GO

SET ANSI_NULLS ON
    GO

SET QUOTED_IDENTIFIER ON
    GO

CREATE VIEW [labkey_etl].[v_delete_valid_dx_group] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 07/15/2019
-- Description:	Selects the valid_dx_groups for LabKey snprc_ehr.valid_dx_group dataset for deletions
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT avd.object_id,
       avd.audit_date_tm


FROM audit.audit_valid_dx_group AS avd

WHERE avd.audit_action = 'D' AND avd.object_id IS NOT NULL



    GO


GRANT SELECT on labkey_etl.v_delete_valid_dx_group to z_labkey
GRANT SELECT ON audit.audit_valid_dx_group TO z_labkey

    go