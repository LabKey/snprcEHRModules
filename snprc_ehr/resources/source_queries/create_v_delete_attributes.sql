USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*==============================================================*/
/* View: V_DELETE_ATTRIBUTES                                         */
/*==============================================================*/
CREATE VIEW [labkey_etl].[V_DELETE_ATTRIBUTES] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 12/30/2015
-- Changes:
--
--
-- ==========================================================================================

SELECT 
	aa.object_id,
	aa.audit_date_tm
FROM audit.audit_attributes AS aa
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = aa.id
WHERE aa.audit_action = 'D' AND aa.object_id IS NOT NULL

GO

GRANT SELECT ON Labkey_etl.V_DELETE_ATTRIBUTES TO z_labkey 
GRANT SELECT ON audit.audit_attributes TO z_labkey

GO

