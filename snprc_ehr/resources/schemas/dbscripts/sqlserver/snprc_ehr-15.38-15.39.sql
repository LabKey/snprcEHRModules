
CREATE TABLE snprc_ehr.validVets (
  vetId  integer NOT NULL,
  displayName varchar(128) NOT NULL ,
  emailAddress varchar(128) NULL,
  status varchar(10) NOT NULL,
  objectid nvarchar(4000) NOT NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

  CONSTRAINT PK_snprc_validVets PRIMARY KEY (vetId),
  CONSTRAINT FK_snprc_validVets FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO