/*
 * New table to configure external reports
 *
 */
EXEC core.fn_dropifexists 'ExternalReports','snprc_ehr', 'TABLE';

CREATE TABLE snprc_ehr.ExternalReports
(
    Id                 INT              IDENTITY(1,1),
    SortOrder          INT              NULL,
    Label              NVARCHAR(64)     NOT NULL,
    Report             NVARCHAR(400)    NOT NULL,
    Description        NVARCHAR(4000)   NOT NULL,
    Parameters         NVARCHAR(4000)   NULL,
    rsParameters       NVARCHAR(4000)   NULL,
    Created            DATETIME         DEFAULT GETDATE(),
    Modified           DATETIME         DEFAULT GETDATE(),
    CreatedBy          USERID,
    ModifiedBy         USERID
        CONSTRAINT PK_ExternalReports PRIMARY KEY CLUSTERED ( Id ASC)
)
