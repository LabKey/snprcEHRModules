USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*==============================================================*/
/* View: V_DELETE_WEIGHT                                               */
/*==============================================================*/
CREATE VIEW [labkey_etl].[v_delete_weight] as
-- ====================================================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/29/2015
--
-- ==========================================================================================
SELECT 
	aw.object_id,
	aw.audit_date_tm

FROM audit.audit_weight AS aw
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = aw.id
WHERE aw.audit_action = 'D' AND aw.object_id IS NOT NULL
 
go

GRANT SELECT on labkey_etl.v_delete_weight to z_labkey
GRANT SELECT ON audit.audit_weight TO z_labkey

go