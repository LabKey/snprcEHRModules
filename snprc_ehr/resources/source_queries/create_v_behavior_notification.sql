/*

 *
 */


--==============================================================
--  View: V_BEHAVIOR_NOTIFICATION
--==============================================================
CREATE VIEW [labkey_etl].[V_BEHAVIOR_NOTIFICATION] AS
/***********************************************************************************************
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 4/9/2020
-- Description:	Selects the ETL records for LabKey Behavior Notification data
--
-- Changes:
-- Not bringing in tid or timestamp
--
***********************************************************************************************/


SELECT bn.notification_number AS NotificationNumber,
       bn.id AS Id,
       bn.reporter AS Reporter,
       bn.location AS Location,
       bn.open_date_tm AS Date,
       bn.close_date_tm as CloseDateTm,
       bn.tid,
       bn.object_id,
       bn.entry_date_tm AS modified,
       dbo.f_map_username(bn.user_name) AS modifiedby,
       tc.created AS created,
       tc.createdby AS createdby,
       bn.timestamp
FROM b_notification bn
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc
                         ON tc.object_id = bn.object_id
    -- select primates only from the TxBiomed colony
         INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d
                    ON d.id = bn.id



