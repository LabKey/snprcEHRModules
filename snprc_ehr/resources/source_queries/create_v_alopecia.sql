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

USE [animal];
GO

/****** Object:  View [labkey_etl].[V_BIRTH]    Script Date: 4/1/2015 10:29:17 AM ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO


ALTER VIEW [labkey_etl].[v_alopecia]
AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 9/21/2017
-- Description:	Selects the ETL records for LabKey study.alopecia dataset
-- Changes:
--
--
-- ==========================================================================================

SELECT  a.ID AS id ,
        a.DATE_TM AS date ,
        a.alopecia AS alopeciaScore ,
        a.OBJECT_ID AS objectid ,
        a.ENTRY_DATE_TM AS modified ,
        dbo.f_map_username(a.USER_NAME) AS modifiedby ,
        tc.created AS created ,
        tc.createdby AS createdby ,
        a.TIMESTAMP AS timestamp
FROM    dbo.v_alopecia a
        INNER JOIN dbo.acq_disp AS ad ON ad.id = a.ID
        LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = a.OBJECT_ID

  -- select primates only from the TxBiomed colony
        INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = a.ID;

GO

GRANT SELECT ON labkey_etl.v_alopecia TO z_labkey;

GO

