USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*==============================================================*/
/* View: V_AUDIT_ACCOUNTS                                               */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_AUDIT_ACCOUNTS] as
-- ====================================================================================================================
-- Object: v_audit_accounts
-- Author:		Terry Hawkins
-- Create date: 6/12/2015
--
-- ==========================================================================================
SELECT 
	aa.object_id,
	aa.audit_date_tm

FROM audit.audit_accounts AS aa
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = aa.id
WHERE aa.AUDIT_ACTION = 'D' AND aa.OBJECT_ID IS NOT NULL

go

GRANT SELECT on labkey_etl.V_AUDIT_ACCOUNTS to z_labkey
GRANT SELECT ON audit.audit_accounts TO z_labkey


go