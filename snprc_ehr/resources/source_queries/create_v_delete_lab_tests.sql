USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [labkey_etl].[V_DELETE_LAB_TESTS] AS
-- ==========================================================================================
-- Object: v_delete_lab_tests
-- Author:		Terry Hawkins
-- Create date: 5/6/2016
--
-- ==========================================================================================
SELECT
	til.object_id,
	til.audit_date_tm

FROM audit.AUDIT_CLINICAL_PATH_TEST_ID_LOOKUP AS til
WHERE til.AUDIT_ACTION = 'D' AND til.OBJECT_ID IS NOT NULL

GO

GRANT SELECT ON labkey_etl.V_DELETE_LAB_TESTS TO z_labkey
GRANT SELECT ON AUDIT.AUDIT_CLINICAL_PATH_TEST_ID_LOOKUP TO z_labkey
go