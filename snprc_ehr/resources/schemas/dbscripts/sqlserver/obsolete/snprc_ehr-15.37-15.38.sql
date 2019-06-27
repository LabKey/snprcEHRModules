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


