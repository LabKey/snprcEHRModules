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

/****** Object:  View [labkey_etl].[V_ANIMAL_GROUPS]    Script Date: 8/28/2015 5:00:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: v_animal_groups                                        */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ANIMAL_GROUPS] AS
-- ====================================================================================================================
-- Object: v_animal_groups
-- Author:		Terry Hawkins
-- Create date: 8/28/2015
--
-- 
-- ==========================================================================================


 SELECT 'Breeding grp:'+CAST(vbg.breeding_grp AS VARCHAR(2)) AS name,
		'Breeding' AS category,
        vbg.description AS comment,
        vbg.ori_date AS date,
        vbg.close_date AS enddate,
        vbg.user_name ,
		vbg.entry_date_tm,
        vbg.object_id AS objectid ,
        vbg.timestamp	
 FROM dbo.valid_breeding_grps AS vbg

 UNION
 SELECT 
		c.colony AS name,
		'Colony' AS category,
        c.description AS comment,
        c.ori_date AS date,
        c.close_date AS enddate,
        c.user_name ,
		c.entry_date_tm,
        c.object_id AS objectid,
        c.timestamp 
FROM dbo.valid_colonies AS c

GO

grant SELECT on labkey_etl.V_ANIMAL_GROUPS to z_labkey

go


