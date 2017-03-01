CREATE TABLE snprc_ehr.animal_groups(
  code INT NOT NULL,
  category_code INT NOT NULL,
  description VARCHAR(128) NOT NULL,
  date DATE NOT NULL,
  enddate DATE NULL,
  comment VARCHAR(MAX) NULL,
  sort_order  INT NULL,
  objectid nvarchar(4000) NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  diCreated DATETIME,
  diModified DATETIME,
  diCreatedBy USERID,
  diModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_animal_groups PRIMARY KEY (code, category_code),
  CONSTRAINT FK_snprc_animal_groups FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO