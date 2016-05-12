
CREATE TABLE snprc_ehr.lab_tests (
  rowid int identity(1,1),
  type varchar(100),
  testid varchar(100) NOT NULL,
  name varchar(100),
  units varchar(100),
  aliases varchar(1000),
  alertOnAbnormal bit,
  alertOnAny bit,
  includeInPanel bit,
  sort_order int,
  userName VARCHAR(128) NOT NULL,
  entryDateTm DATETIME NOT NULL,
  objectid nvarchar(4000),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

CONSTRAINT PK_snprc_lab_tests PRIMARY KEY (rowid),
CONSTRAINT FK_snprc_lab_tests FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE INDEX IDX_snprc_lab_tests_test_id ON snprc_ehr.lab_tests (testid);

GO


CREATE TABLE snprc_ehr.labwork_services (
  servicename varchar(200) NOT NULL,
  serviceid varchar(200) NOT NULL,
  dataset varchar(200),
  chargetype varchar(200),
  collectionmethod varchar(500),
  alertOnComplete bit,
  tissue varchar(100),
  outsidelab bit,
  datedisabled datetime,
  method varchar(100),
  userName VARCHAR(128) NOT NULL,
  entryDateTm DATETIME NOT NULL,
  objectid nvarchar(4000),
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_labwork_services PRIMARY KEY (servicename),
  CONSTRAINT FK_snprc_labwork_services FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO
