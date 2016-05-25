
CREATE TABLE snprc_ehr.validInstitutions (
  institution_id integer NOT NULL ,
  institution_name varchar(200) NOT NULL,
  short_name varchar(20) NOT NULL,
  city varchar(50) NOT NULL,
  state varchar(20) NOT NULL,
  affiliate varchar(50) NULL,
  web_site varchar(200) NULL,
  objectid nvarchar(4000) NOT NULL,
  Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
  Container	entityId NOT NULL,

CONSTRAINT PK_snprc_valid_institutions PRIMARY KEY (institution_id),
CONSTRAINT FK_snprc_valid_institutions FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
);

GO


