/*

 *
 */

--==============================================================
--  View: V_BEHAVIOR_NOTIFICATION_COMMENT
--==============================================================
CREATE VIEW [labkey_etl
].[V_BEHAVIOR_NOTIFICATION_COMMENT
] AS
/***********************************************************************************************
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 4/9/2020
-- Description:	Selects the ETL records for LabKey Behavior Notification data
--				NOTE: Includes lookup/valid table columns.
						Does NOT INCLUDE animal IDs
				Will use b_c_notification (bcn) object_id, usernames and timestamps
-- Changes:
    Updated created and createdby
        COALESCE(tc.created, bn.entry_date_tm) AS created ,
        COALESCE(tc.createdby, dbo.f_map_username(bn.user_name)) AS createdBy
--
***********************************************************************************************/

SELECT bcn.notification_number                                                    AS NotificationNumber,
       bcn.notifi_date_tm                                                         AS NotificationDateTm,
       bcn.behavior_id                                                            AS BehaviorId,
       bcn.beh_notifi_status                                                      AS NotificationStatus,
       bcn.case_number                                                            AS CaseNumber,
       bcn.beh_notifi_comments                                                    AS NotificationComments,
       bcn.susp_behavior                                                          AS SuspiciousBehavior,
       bcn.sib                                                                    AS Sib,
       bcn.housing_type                                                           AS HousingType,
       vb.behavior                                                                AS Behavior,
       vb.abnormal_flag                                                           AS AbnormalFlag,
       vb.description                                                             AS BehaviorDescription,
       vb.category                                                                AS BehaviorCategory,
       vb.comments                                                                AS BehaviorComments,
       dbo.f_map_username(bcn.user_name)                                          AS modifiedby,
       bcn.entry_date_tm                                                          AS modified,
       COALESCE(tc.created, bcn.entry_date_tm)                                     AS created,
       COALESCE(tc.createdby, dbo.f_map_username(bcn.user_name))                   AS createdBy,
       bcn.object_id                                                              as ObjectId,
       --bcn.timestamp AS timestamp
       (SELECT MAX(v) FROM (VALUES (vb.timestamp), (bcn.timestamp)) AS VALUE (v)) AS timestamp

FROM b_c_notification bcn
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc
                         ON tc.object_id = bcn.object_id
         INNER JOIN valid_behaviors vb
                    ON bcn.behavior_id = vb.behavior_id;
