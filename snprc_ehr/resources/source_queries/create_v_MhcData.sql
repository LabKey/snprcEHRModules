/*
 * Copyright (c) 2015-2017 LabKey Corporation
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

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

ALTER VIEW [labkey_etl].[V_MhcData]
AS
    -- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 9/8/2017
-- Description:
-- Changes:
--
--
-- ==========================================================================================

SELECT  m.[Animal ID] AS id ,
        m.[OC ID] AS OcId ,
        m.[MHC value] AS MhcValue ,
        m.Haplotype AS Haplotype ,
        m.[Data File Source] AS DataFileSource,
		m.objectid AS objectid
FROM    dbo.MhcData AS m -- select primates only from the TxBiomed colony
        INNER JOIN labkey_etl.V_DEMOGRAPHICS AS d ON d.id = m.[Animal ID];

GO

GRANT SELECT ON labkey_etl.V_MhcData TO z_labkey;

GO

