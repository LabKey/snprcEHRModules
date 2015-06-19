USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*==============================================================*/
/* View: V_AUDIT_LOCATION                                               */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_AUDIT_LOCATION] as
-- ====================================================================================================================
-- Object: v_audit_location
-- Author:		Terry Hawkins
-- Create date: 6/12/2015
--
-- ==========================================================================================
SELECT 
	l.id,
	l.move_date_tm,
	l.location,
	l.exit_date_tm,
	l.object_id,
	l.user_name,
	l.entry_date_tm,
	l.audit_timestamp,
	l.audit_action,
	l.audit_date_tm,
	l.audit_user_name

FROM audit.audit_location AS l
--WHERE l.move_date_tm > '1/1/2014 00:00'
go

grant SELECT on labkey_etl.V_AUDIT_LOCATION to z_labkey
grant SELECT on labkey_etl.V_AUDIT_LOCATION to z_camp_base
GRANT SELECT, INSERT ON audit.audit_location TO z_labkey

go