CREATE TABLE snprc_ehr.animal_group_categories(
  category_code int IDENTITY(1,1) NOT NULL,
  description varchar(128) NULL,
  comment varchar(128) NULL,
  displayable char(1) NOT NULL,
  species char(2) NULL,
  sex char(1) NULL,
  enforce_exclusivity char(1) NOT NULL,
  allow_future_date char(1) NOT NULL,
  sort_order int NULL,
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

  CONSTRAINT PK_animal_group_categories PRIMARY KEY (category_code),
  CONSTRAINT FK_animal_group_categories FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO