USE [animal]
GO

/****** Object:  View [labkey_etl].[V_DELETE_ANIMAL_PROCEDURES]    Script Date: 11/5/2015 10:09:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_DELETE_ANIMAL_PROCEDURES                             */
/*==============================================================*/
CREATE VIEW [labkey_etl].[V_DELETE_ANIMAL_PROCEDURES] AS
-- =========================================================================================
-- Author:		Terry Hawkins
-- Create date: 11/3/2015
--
-- ==========================================================================================
SELECT 
	acp.object_id,
	acp.audit_date_tm

FROM audit.AUDIT_CODED_PROCS AS acp
-- select primates only from the TxBiomed colony
WHERE acp.AUDIT_ACTION = 'D' AND acp.OBJECT_ID IS NOT NULL


GO


