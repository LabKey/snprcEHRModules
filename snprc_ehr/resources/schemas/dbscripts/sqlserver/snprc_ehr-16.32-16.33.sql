/*
 * Copyright (c) 2017 LabKey Corporation
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
CREATE TABLE snprc_ehr.animal_group_categories(
  category_code int NOT NULL,
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