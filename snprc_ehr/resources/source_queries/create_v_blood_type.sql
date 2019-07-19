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
/* View: v_blood_type data                                             */
/*==============================================================*/
create VIEW [labkey_etl].[v_blood_type] as
-- ====================================================================================================================
-- Object: v_blood_type
-- Author:		Scott Rouse
-- Create date: 02/14/2019
-- Note: sourced from v_vaccine
--
-- ==========================================================================================
SELECT bt.id				AS Id,
       bt.type_date			AS date,
       bt.blood_type		AS BloodType,
       bt.object_id			AS objectid,
	   bt.entry_date_tm					AS modified,
       dbo.f_map_username(bt.user_name)	AS modifiedBy,
	   tc.created						AS created,
       tc.createdby						AS createdby,
       bt.timestamp 
		FROM dbo.blood_type bt
		INNER JOIN dbo.TAC_COLUMNS tc
			ON tc.object_id = bt.object_id

 GO

GRANT SELECT ON Labkey_etl.V_blood_type TO z_labkey
  GO