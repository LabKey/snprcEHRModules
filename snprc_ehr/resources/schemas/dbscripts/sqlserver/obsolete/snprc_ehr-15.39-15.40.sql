/*
 * Copyright (c) 2018-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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