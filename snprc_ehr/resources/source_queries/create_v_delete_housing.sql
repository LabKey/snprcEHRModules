USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*==============================================================*/
/* View: V_AUDIT_LOCATION                                               */
/*==============================================================*/
ALTER VIEW [labkey_etl].[v_delete_housing] as
-- ====================================================================================================================
-- Object: v_audit_location
-- Author:		Terry Hawkins
-- Create date: 6/12/2015
--
-- ==========================================================================================
SELECT 
	al.object_id,
	al.audit_date_tm

FROM audit.audit_location AS al
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = al.id
WHERE al.audit_action = 'D' AND al.object_id IS NOT NULL
 
go

GRANT SELECT on labkey_etl.v_delete_housing to z_labkey
GRANT SELECT ON audit.audit_location TO z_labkey

go