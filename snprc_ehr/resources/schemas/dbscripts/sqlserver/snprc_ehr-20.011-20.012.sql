/*
 * New table to track number of animals allowed and assigned to IACUC protocols
 * 9/25/2020 tjh
 */
EXEC core.fn_dropifexists 'IacucAssignmentStats','snprc_ehr', 'TABLE';

CREATE TABLE snprc_ehr.IacucAssignmentStats
(
    ThreeYearPeriod    INT              NOT NULL,
    WorkingIacuc       NVARCHAR(50)     NOT NULL,
    ArcNumSeq          INT              NOT NULL,
    arcNumGenus        VARCHAR(50)      NOT NULL,
    FirstAmendment     INT              NOT NULL,
    LastAmendment      INT              NOT NULL,
    StartDate          DATETIME         NOT NULL,
    EndDate            DATETIME         NULL,
    NumAnimalsAllowed  INT              NOT NULL,
    NumAnimalsAssigned INT              NOT NULL,
    diCreated          DATETIME,
    diModified         DATETIME,
    diCreatedBy        USERID,
    diModifiedBy       USERID,
    Container          entityId         NOT NULL
    CONSTRAINT PK_IacucAssignmentStats PRIMARY KEY CLUSTERED ( WorkingIacuc ASC, ThreeYearPeriod ASC ),
    CONSTRAINT FK_IacucAssignmentsStats_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
)
