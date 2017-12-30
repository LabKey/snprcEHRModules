EXEC core.fn_dropifexists 'FeeSchedule','snprc_ehr', 'TABLE';
GO

CREATE TABLE [snprc_ehr].[FeeSchedule](
  [RowId] [bigint] IDENTITY(1,1) NOT NULL,
  [ActivityId] INTEGER NOT NULL,
  [Species] NVARCHAR(128) NOT NULL,
  [Description] NVARCHAR (256) NOT NULL,
  [BudgetYear] NVARCHAR (256) NOT NULL,
  [Cost] NUMERIC (5,2) NOT NULL,
  [FileName] NVARCHAR (256) NOT NULL,
  [ObjectId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
  [Created] [DATETIME] NULL,
  [CreatedBy] [dbo].[USERID] NULL,
  [Modified] [DATETIME] NULL,
  [ModifiedBy] [dbo].[USERID] NULL,
  Container	entityId NOT NULL


    CONSTRAINT PK_snprc_fee_schedule PRIMARY KEY ([RowId])
    CONSTRAINT FK_snprc_fee_Schedule_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId) );

CREATE UNIQUE INDEX idx_snprc_fee_schedule_objectid ON snprc_ehr.feeSchedule (objectid)
CREATE UNIQUE INDEX idx_snprc_fee_schedule_activityId_budgetYear ON snprc_ehr.FeeSchedule (ActivityId, BudgetYear);


