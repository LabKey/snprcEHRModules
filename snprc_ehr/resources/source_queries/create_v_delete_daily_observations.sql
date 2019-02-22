USE [animal]
GO

SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO

/*==============================================================*/
/* View: V_DELETE_DAILY_OBSERVATIONS                                      */
/*==============================================================*/
CREATE VIEW [labkey_etl].[v_delete_daily_observations] as
-- ====================================================================================================================
-- Object: V_DELETE_DAILY_OBSERVATIONS
-- Author:	Scott Rouse
-- Create date: 01/29/2019
--

-- sourced from: V_DELETE_ACCOUNTS
-- ==========================================================================================
SELECT ao.object_id, ao.audit_date_tm
FROM audit.audit_observations ao

       -- select primates only from the TxBiomed colony
       INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ao.id
WHERE ao.AUDIT_ACTION = 'D' AND ao.OBJECT_ID IS NOT NULL;

 go

GRANT SELECT on labkey_etl.[V_DELETE_DAILY_OBSERVATIONS] to z_labkey;
GRANT SELECT ON audit.audit_observations TO z_labkey;


  go