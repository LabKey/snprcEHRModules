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
USE [animal]
GO

SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO

/*==============================================================*/
/* View: v_vaccine data                                             */
/*==============================================================*/
Alter VIEW [labkey_etl].[v_vaccine] as
-- ====================================================================================================================
-- Object: v_vaccines
-- Author:		Scott Rouse
-- Create date: 02/14/2019
-- Note: sourced from v_vaccine
--
-- ==========================================================================================

SELECT v.ID 							AS Id,
       v.VACCINATION_DATE				AS Date,
       v.vaccine						AS Vaccine,
       v.PKG_ID							AS PkgId,
       v.PROC_ID						AS ProcId,
       v.OBJECT_ID						AS objectid,
       v.ENTRY_DATE_TM					AS modified,
       dbo.f_map_username(v.USER_NAME)	AS modifiedBy,
       tc.created						AS created,
       tc.createdby						AS createdby,
       v.TIMESTAMP

FROM dbo.V_VACCINE v
       INNER JOIN dbo.TAC_COLUMNS tc
                  ON tc.object_id = v.OBJECT_ID



       GO

GRANT SELECT ON Labkey_etl.v_vaccine TO z_labkey
       GO