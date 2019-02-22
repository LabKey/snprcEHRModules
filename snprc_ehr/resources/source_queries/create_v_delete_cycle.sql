/**************************************
srr 02.07.2019
Wide table replacement for OLDcreate_v_delete_cycle.sql

***************************************/

USE [animal]
GO

SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO


/*==============================================================*/
/* View: V_DELETE_CYCLE                                         */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_DELETE_CYCLE] AS
-- ==========================================================================================
-- Author:	Scott Rouse
-- Create date: 02/08/2019
--
-- srr 02.11.19 renamed to v_delete_cycle.sql
-- ==========================================================================================


SELECT  
	ac.object_id,
	ac.audit_date_tm
FROM audit.audit_cycle ac
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ac.id
WHERE ac.audit_action = 'D' AND ac.object_id IS NOT NULL
go




GRANT SELECT ON labkey_etl.V_DELETE_CYCLE TO z_labkey
GRANT SELECT ON audit.AUDIT_CYCLE TO z_labkey
  go
