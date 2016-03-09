USE [animal]
GO

/****** Object:  View [labkey_etl].[V_DELETE_VALID_ACCOUNTS]    Script Date: 3/9/2016 10:29:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [labkey_etl].[V_DELETE_VALID_ACCOUNTS] AS
-- ====================================================================================================================
-- Object: v_delete_valid_accounts
-- Author:		Terry Hawkins
-- Create date: 3/4/2016
--
-- ==========================================================================================
SELECT
	ava.object_id,
	ava.audit_date_tm

FROM audit.audit_valid_accounts AS ava
WHERE ava.AUDIT_ACTION = 'D' AND ava.OBJECT_ID IS NOT NULL

GO
