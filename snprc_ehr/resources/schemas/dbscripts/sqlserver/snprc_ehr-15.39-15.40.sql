CREATE TABLE snprc_ehr.valid_bd_status (
  value  integer NOT NULL,
  description varchar(128) NOT NULL ,
  objectid nvarchar(4000) NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_valid_bd_status PRIMARY KEY (value),
  CONSTRAINT FK_snprc_valid_bd_status FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO
CREATE TABLE snprc_ehr.valid_birth_code (
  value  integer NOT NULL,
  description varchar(128) NOT NULL ,
  objectid nvarchar(4000) NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_valid_birth_code PRIMARY KEY (value),
  CONSTRAINT FK_snprc_valid_birth_code FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO

CREATE TABLE snprc_ehr.valid_death_code (
  value  integer NOT NULL,
  description varchar(128) NOT NULL ,
  objectid nvarchar(4000) NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_valid_death_code PRIMARY KEY (value),
  CONSTRAINT FK_snprc_valid_death_code FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO