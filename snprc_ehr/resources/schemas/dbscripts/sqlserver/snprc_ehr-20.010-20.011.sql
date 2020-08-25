/*******************************************************
Counters table for SNPRC_EHRSequencer
  Creator: thawkins
  Date: 08/21/2020
*******************************************************/

CREATE TABLE snprc_ehr.Counters
(
    RowId                  INT IDENTITY(1,1) NOT NULL,
    Name                   NVARCHAR(255)    NOT NULL,
    Value                  INT              NOT NULL,
    Container              dbo.ENTITYID     NOT NULL,
    ObjectId               UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    CONSTRAINT PK_snprc_Counters PRIMARY KEY (RowId),
    CONSTRAINT FK_Counters_Container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);
GO

CREATE UNIQUE INDEX idx_snprc_container_NameValue ON snprc_ehr.Counters (Container, Name, Value);
GO
