/*
 * Copyright (c) 2015 LabKey Corporation
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
/* View: v_animal_group_members                                 */
/*==============================================================*/
CREATE VIEW [labkey_etl].[V_ANIMAL_GROUP_MEMBERS] as
-- ====================================================================================================================
-- Object: v_animal_group_members
-- Author: Terry Hawkins
-- Create date: 8/28/2015
--
-- 11/12/15 - Added 'Breeding grp:' to groupName to match v_animal_groups. tjh
-- ==========================================================================================


 SELECT LTRIM(RTRIM(bg.id)) AS id ,
		'Breeding' AS GroupCategory,
		'Breeding grp:'+CAST(bg.breeding_grp AS VARCHAR(2)) AS GroupName,
        bg.start_date AS date,
        bg.end_date AS enddate,
        bg.user_name ,
        bg.object_id as objectid,
        bg.entry_date_tm ,
        bg.timestamp
 FROM dbo.breeding_grp AS bg
 INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = bg.id

 UNION
 SELECT LTRIM(RTRIM(c.id)) AS id ,
		'Colony' AS GroupCategory,
		c.colony AS GroupName,
        c.start_date_tm AS date,
        c.end_date_tm AS enddate,
        c.user_name ,
        c.object_id as objectid,
        c.entry_date_tm ,
        c.timestamp 
FROM dbo.colony AS c
INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = c.id

GO

grant SELECT on labkey_etl.V_ANIMAL_GROUP_MEMBERS to z_labkey

go