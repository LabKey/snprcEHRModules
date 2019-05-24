/*******************************************
Add AnimalAccount to Timeline table
Will hold a concated list of animal acccount
for this project.
NOTE: Reference only, not validated
srr 05.22.2019
*******************************************/
ALTER TABLE snprc_scheduler.Timeline
    ADD AnimalAccount NVARCHAR(255) NULL;
GO
/******************************************
Add alternate key to TimlelineItem
for reference to the new StudyDayNotes table
srr 05.22.2019
*******************************************/

ALTER TABLE snprc_scheduler.TimelineItem
    ADD CONSTRAINT AK_AK_STUDYDAYNOTES_TIMELINE
        UNIQUE (
                TimelineObjectId,
                StudyDay
            );
GO



/********************************************
Create table to hold day specific study notes.

C:\MySoftware\labkey\trunk\externalModules\snprcEHRModules
snprcEHRModules
srr 05.22.2019
*********************************************/
/*==============================================================*/
/* Table: StudyDayNotes                                         */
/*==============================================================*/
CREATE TABLE snprc_scheduler.StudyDayNotes
(
    ObjectId ENTITYID NOT NULL,
    TimelineObjectId UNIQUEIDENTIFIER NULL,
    StudyDay INT NULL,
    StudyDayNote NVARCHAR(MAX) NULL,
    QcState INT NULL,
    Created DATETIME NULL,
    CreatedBy INT NULL,
    Modified DATETIME NULL,
    ModifiedBy INT NULL
);
GO

ALTER TABLE snprc_scheduler.StudyDayNotes
    ADD CONSTRAINT PK_STUDYDAYNOTES
        PRIMARY KEY (ObjectId);
GO

-- Reference is not to unique row
-- will handle integrity via a different mechanism
-- srr 05.24.2019
/*
ALTER TABLE snprc_scheduler.StudyDayNotes
    ADD CONSTRAINT FK_STUDYDAY_FK_TIMELI_TIMELINE
        FOREIGN KEY (
                     TimelineObjectId,
                     StudyDay
            )
            REFERENCES snprc_scheduler.TimelineItem (
                                                     TimelineObjectId,
                                                     StudyDay
                );
*/