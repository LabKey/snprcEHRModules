
EXEC core.fn_dropifexists 'ValidDiet','snprc_ehr', 'TABLE';

/*****************************************************************
Note:  ArcSpeciesCode is null for most rows
therefore not included in PK
PK is composite of Diet and StartDate

Currently: In legacy table, SnomedCode is
generated using a identity (tid).
As of 03.18.2019 column is now DietCode.

This was refactored to an integer
DietId.
May refactor out or to a counter
value at a later date.

srr 03.11.2019 ori
srr 03.18.2019 To agree w/ naming conventions elsewhere
refactored DietId to DietCode


******************************************************************/

CREATE TABLE snprc_ehr.ValidDiet(
  [Diet] [nvarchar](20) NOT NULL,
  [ArcSpeciesCode] [nvarchar](2) NULL,
  [StartDate] [datetime] NOT NULL,
  [StopDate] [datetime] NULL,
  [SnomedCode] [nvarchar](7) NULL,
  [DietCode]	[INTEGER] NOT NULL,
  --ObjectId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
  --[Container] [entityID] NOT NULL,
  [Created]	DATETIME,
  [CreatedBy] USERID,
  [Modified]	DATETIME,
  [ModifiedBy] USERID,
  [diCreated] [datetime] NULL,
  [diModified] [datetime] NULL,
  [diCreatedBy] [dbo].[USERID] NULL,
  [diModifiedBy] [dbo].[USERID] NULL,
  [Container] [dbo].[ENTITYID] NOT NULL,
  [objectid] [uniqueidentifier] NOT NULL
  CONSTRAINT [PK_ValidDiet] PRIMARY KEY CLUSTERED ([Diet] ASC,[StartDate] ASC)
  )

-- will need to be changed if we begin to use Diet instead of SnomedCode srr
CREATE UNIQUE INDEX idx_ValidDiet_SnomedCode_StartStopDate ON snprc_ehr.ValidDiet(SnomedCode, StartDate, StopDate);
  go