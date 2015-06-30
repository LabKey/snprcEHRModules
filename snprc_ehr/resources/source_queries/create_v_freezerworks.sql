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
    -- ====================================================================================================================
-- Object: V_FREEZERWORKS
-- Author:	Scott Rouse
-- Create date: 06/26/2015
--
-- ==========================================================================================

SELECT  [TBRI_id] AS id ,
 --FW_ID AS Freezerworks_ID,
        [DATE_COLLECTED] ,
        [aliq_create_date] ,
        [aliq_mod_date] ,
        [sample_create_date] ,
        [NECROPSY] ,
        [SHIPMENTSTATUS] ,
        [sample_deleted] ,
        [aliq_deleted] ,
        [PK_SAMPLEUID] ,
        [PK_ALIQUOTUID] ,
        [SAMPLE_TYPES] ,
        [COMMENTS] ,
        [NUMBEROFALIQUOTSWITHPOSITIONS] ,
        [CURRMAXALIQUOTNUMBER] ,
        [NUMBEROFALIQUOTSTOTAL] ,
        [INITIALAMOUNT] ,
        [STORAGE_VIAL] ,
        [CONCENTRATION] ,
        [CURRENTAMOUNT] ,
        [Freezer_desc] ,
        [FREEZERNAME]
--, [SUBDIVISION1], [SUBDIVISION2], [SUBDIVISION3], [SUBDIVISION4], [SUBDIVISION5]
        ,
        [POSITION1] ,
        [POSITION2] ,
        [POSITION3] ,
        [POSITION4] ,
        [POSITION5] ,
        [object_id] ,
        [user_name] ,
        [entry_date_tm] ,
        [timestamp]
FROM    [freezerworks].[SAMPLE_ALIQ]

GO

GRANT SELECT ON labkey_etl.v_freezerworks TO z_labkey
GRANT SELECT ON freezerworks.SAMPLE_ALIQ TO z_labkey

GO

