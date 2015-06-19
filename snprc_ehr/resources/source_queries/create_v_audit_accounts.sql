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
	aa.id,
	aa.assign_date, -- as date,
	aa.account,
	aa.end_date, -- as enddate,
	aa.object_id, -- as objectid,
	aa.user_name, -- as username,
	aa.entry_date_tm,
	aa.audit_timestamp,
	aa.audit_action,
	aa.audit_date_tm,
	aa.audit_user_name

FROM audit.audit_accounts AS aa
--WHERE aa.assign_date > '1/1/2014 00:00'
go

grant SELECT on labkey_etl.V_AUDIT_ACCOUNTS to z_labkey
grant SELECT on labkey_etl.V_AUDIT_ACCOUNTS to z_camp_base
GRANT INSERT, SELECT ON audit.audit_accounts TO z_labkey


go