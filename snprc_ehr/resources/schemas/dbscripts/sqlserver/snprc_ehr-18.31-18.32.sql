/*
 * Copyright (c) 2019 LabKey Corporation
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
EXEC core.fn_dropifexists 'LocationTemperature','snprc_ehr', 'TABLE';

GO
/*************************************
ObjectId should be populated before insert.


srr 02.25.2019
*************************************/

CREATE TABLE [snprc_ehr].[LocationTemperature](
  [Room] [varchar](100) NOT NULL,
  [Date] [DATETIME] NOT NULL,
  [LowTemperature] [NUMERIC](6, 2) NULL,
  [HighTemperature] [NUMERIC](6, 2) NULL,
  [Notify] [VARCHAR](18) NULL,
  [ObjectId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
  [user_name] [VARCHAR](128) NOT NULL,
  [entry_date_tm] [DATETIME] NOT NULL,
  [Container] [entityID] NOT NULL,
  [Created]	DATETIME,
  [CreatedBy] USERID,
  [Modified]	DATETIME,
  [ModifiedBy] USERID

  CONSTRAINT [PK_LocationTemperature] PRIMARY KEY CLUSTERED ([Room] ASC,[Date] ASC)
  CONSTRAINT FK_snprc_LocationTemperature_container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)

  )
  GO


CREATE UNIQUE INDEX idx_snprc_LocationTemperature_objectid ON snprc_ehr.LocationTemperature (ObjectId);
CREATE UNIQUE INDEX idx_snprc_LocationTemperature_Room ON snprc_ehr.LocationTemperature (Room);
GO
