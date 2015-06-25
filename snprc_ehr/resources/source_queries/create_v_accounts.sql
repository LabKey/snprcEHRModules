USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*==============================================================*/
/* View: V_ACCOUNTS                                             */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ACCOUNTS] as
-- ====================================================================================================================
-- Object: v_accounts
-- Author:		Terry Hawkins
-- Create date: 6/11/2015
--
-- 6/24/2015 added entry_date_tm. tjh
-- ==========================================================================================


SELECT
a.id,
a.assign_date, -- as date,
a.account,
a.end_date, -- as enddate,
a.object_id, -- as objectid,
a.user_name, -- as username,
a.entry_date_tm,
a.timestamp

from dbo.accounts a
JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = a.id
--WHERE a.assign_date > '1/1/2014 00:00'
go

grant SELECT on labkey_etl.V_ACCOUNTS to z_labkey
grant SELECT on labkey_etl.V_ACCOUNTS to z_camp_base


go