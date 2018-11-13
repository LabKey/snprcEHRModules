/*
 * Copyright (c) 2016 LabKey Corporation
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
CREATE TABLE snprc_ehr.validAccounts(
	account varchar(16) NOT NULL,
	accountStatus varchar(1) NOT NULL,
	date DATETIME NOT NULL,
	endDate DATETIME NULL,
	description VARCHAR(100) NULL,
	accountGroup VARCHAR(20) NOT NULL,
	userName VARCHAR(128) NOT NULL,
	entryDateTm DATETIME NOT NULL,
	Container	entityId NOT NULL,
	Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
	objectid NVARCHAR(4000)

 CONSTRAINT [PK_VALID_ACCOUNTS] PRIMARY KEY CLUSTERED (	account ASC )

);
GO