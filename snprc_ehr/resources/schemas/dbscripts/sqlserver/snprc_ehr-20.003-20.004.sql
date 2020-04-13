-- generated w/o issue from SSMS srr 04.10.20

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
    Created              DATETIME         NULL,
    CreatedBy            USERID           NULL,
    Modified             DATETIME         NULL,
    ModifiedBy           USERID           NULL,
    user_name            VARCHAR(128)     NULL,
    entry_date_tm        DATETIME         NULL,
    Container            ENTITYID         NOT NULL,
    objectid             UNIQUEIDENTIFIER NULL,
    TIMESTAMP            TIMESTAMP        NULL,
    CONSTRAINT PK_BehaviorNotiComment PRIMARY KEY (NotificationNumber)
);