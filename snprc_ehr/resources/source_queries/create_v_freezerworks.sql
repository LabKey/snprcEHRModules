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

/****** Object:  View [labkey_etl].[V_FREEZERWORKS]    Script Date: 6/29/2015 11:31:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_FREEZERWORKS                                         */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_FREEZERWORKS]
AS
-- ==========================================================================================
-- Object: V_FREEZERWORKS
-- Author:	Scott Rouse
-- Create date: 06/26/2015
--
-- 4/4/2016	Joined with labkey_etl table to only bring in samples for txbiomed animals. tjh
-- ==========================================================================================

SELECT  f.[TBRI_id] AS id ,
 --FW_ID AS Freezerworks_ID,
		f.[DATE_COLLECTED] AS date,
        f.[aliq_create_date] ,
        f.[aliq_mod_date] ,
        f.[sample_create_date] ,
        f.[NECROPSY] ,
        f.[SHIPMENTSTATUS] ,
        f.[sample_deleted] ,
        f.[aliq_deleted] ,
        f.[PK_SAMPLEUID] ,
        f.[PK_ALIQUOTUID] ,
        f.[SAMPLE_TYPES] ,
        f.[COMMENTS] ,
        f.[NUMBEROFALIQUOTSWITHPOSITIONS] ,
        f.[CURRMAXALIQUOTNUMBER] ,
        f.[NUMBEROFALIQUOTSTOTAL] ,
        f.[INITIALAMOUNT] ,
        f.[STORAGE_VIAL] ,
        f.[CONCENTRATION] ,
        f.[CURRENTAMOUNT] ,
        f.[Freezer_desc] ,
        f.[FREEZERNAME]
--, [SUBDIVISION1], [SUBDIVISION2], [SUBDIVISION3], [SUBDIVISION4], [SUBDIVISION5]
        ,
        f.[POSITION1] ,
        f.[POSITION2] ,
        f.[POSITION3] ,
        f.[POSITION4] ,
        f.[POSITION5] ,
        f.[object_id] ,
        f.[user_name] ,
        f.[entry_date_tm] ,
        f.[timestamp]
FROM    [freezerworks].[SAMPLE_ALIQ] AS f
INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON f.tbri_id = d.id
WHERE f.[DATE_COLLECTED] IS NOT NULL

GO

GRANT SELECT ON labkey_etl.v_freezerworks TO z_labkey
GRANT SELECT ON freezerworks.SAMPLE_ALIQ TO z_labkey

GO

