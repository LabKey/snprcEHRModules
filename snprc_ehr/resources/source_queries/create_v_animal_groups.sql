/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
USE [animal];
GO

/****** Object:  View [labkey_etl].[V_ANIMAL_GROUPS]    Script Date: 8/28/2015 5:00:40 PM ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO


/*==============================================================*/
/* View: v_animal_groups                                        */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ANIMAL_GROUPS]
AS
    -- ====================================================================================================================
-- Object: v_animal_groups
-- Author:		Terry Hawkins
-- Create date: 8/28/2015
--
-- 3/1/2016	Added pedigree data. tjh
-- 3/3/2016 Added account_group. tjh
-- 11/4/2016 added modified, modifiedby, created, createdby columns. tjh
-- 2/20/2017  complete re-write.  Data now comes from animal_groups table. tjh
-- 3/7/2017 aliased description column to name. tjh
-- ==========================================================================================

SELECT  ag.code ,
        ag.category_code ,
        ag.description as name,
        ag.start_date AS date ,
        ag.end_date AS enddate ,
        ag.comment ,
        ag.sort_order ,
        ag.object_id AS objectid ,
        ag.entry_date_tm AS modified ,
        dbo.f_map_username(ag.user_name) AS modifiedby ,
        tc.created AS created ,
        tc.createdby AS createdby ,
        ag.timestamp
FROM    animal_groups AS ag
        LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = ag.object_id

GO

GRANT SELECT ON labkey_etl.V_ANIMAL_GROUPS TO z_labkey;

GO