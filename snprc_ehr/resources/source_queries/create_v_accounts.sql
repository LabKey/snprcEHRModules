USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*==============================================================*/
/* View: V_ACCOUNTS                                             */
/*==============================================================*/
CREATE
 VIEW [labkey_etl].[V_ACCOUNTS] as
-- ====================================================================================================================
-- Object: v_accounts
-- Author:		Terry Hawkins
-- Create date: 6/11/2015
--
-- ==========================================================================================


SELECT
a.id,
a.assign_date, -- as date,
a.account,
a.end_date, -- as enddate,
a.object_id, -- as objectid,
a.user_name, -- as username,
a.timestamp

from dbo.accounts a
--WHERE a.assign_date > '1/1/2014 00:00'
go

grant SELECT on labkey_etl.V_ACCOUNTS to z_labkey
grant SELECT on labkey_etl.V_ACCOUNTS to z_camp_base


go