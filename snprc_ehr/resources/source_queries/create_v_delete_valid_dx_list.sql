USE [animal]
GO

SET ANSI_NULLS ON
    GO

SET QUOTED_IDENTIFIER ON
    GO

CREATE VIEW [labkey_etl].[v_delete_valid_dx_list] AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 07/15/2019
-- Description:	Selects the valid_dx_lists for LabKey snprc_ehr.valid_dx_list dataset for deletions
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT avd.object_id,
       avd.audit_date_tm


FROM audit.audit_valid_dx_list AS avd

WHERE avd.audit_action = 'D' AND avd.object_id IS NOT NULL



    GO


GRANT SELECT on labkey_etl.v_delete_valid_dx_list to z_labkey
GRANT SELECT ON audit.audit_valid_dx_list TO z_labkey

    go