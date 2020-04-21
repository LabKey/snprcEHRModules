-- generated w/o issue from SSMS srr 04.10.20
-- schemas/dbscripts/sqlserver/snprc_ehr-20.003-20.004.sql
-- changed pk to tid idenity
EXEC core.fn_dropifexists 'BehaviorNotificationComment','snprc_ehr', 'TABLE';


CREATE TABLE snprc_ehr.BehaviorNotificationComment
(
    NotificationNumber   INT              NOT NULL,
    NotificationDateTm   DATETIME         NOT NULL,
    BehaviorId           INT              NOT NULL,
    NotificationStatus   INT              NOT NULL,
    CaseNumber           INT              NULL,
    NotificationComments VARCHAR(255)     NULL,
    SuspiciousBehavior   CHAR(1)          NOT NULL,
    Sib                  CHAR(1)          NOT NULL,
    HousingType          INT              NULL,
    Behavior             VARCHAR(30)      NOT NULL,
    AbnormalFlag         CHAR(1)          NOT NULL,
    BehaviorDescription  VARCHAR(200)     NOT NULL,
    BehaviorCategory     VARCHAR(40)      NULL,
    BehaviorComments     VARCHAR(200)     NULL,
    Container            ENTITYID         NOT NULL,
    Created              DATETIME         NULL,
    CreatedBy            USERID           NULL,
    ModifiedBy           USERID           NULL,
    Modified             DATETIME         NULL,
    DiCreatedBy          USERID           NULL,
    DiCreated            DATETIME         NULL,
    DiModifiedBy         USERID           NULL,
    DiModified           DATETIME         NULL,
    tid                  INT              IDENTITY,
    objectid             UNIQUEIDENTIFIER NULL
        CONSTRAINT PK_BehaviorNotiComment_oid PRIMARY KEY (tid)
);