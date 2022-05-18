/*
 * Copyright (c) 2017-2018 LabKey Corporation
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

ALTER VIEW [labkey_etl].[V_MhcData] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 5/16/2017
-- Description:	
-- Changes:
-- 05/18/2022 removed leading spaces from animal id
--
-- ==========================================================================================

SELECT
	u.[Animal ID] AS Id,
	u.[File Source] AS DataFileSource,
	u.[OC ID] AS OcId,
	u.Haplotype AS Haplotype,
	u.[MHC Value] AS MhcValue

FROM (SELECT
	[ANIMAL ID],
    [File Source],
    [OC ID],
    [Mamu-A Haplotype 1],
    [Mamu-A Haplotype 2],
    [Mamu-B Haplotype 1],
    [Mamu-B Haplotype 2],
    [Mamu-DRB Haplotype 1],
    [Mamu-DRB Haplotype 2],
    [Mamu-DQA Haplotype 1],
    [Mamu-DQA Haplotype 2],
    [Mamu-DQB Haplotype 1],
    [Mamu-DQB Haplotype 2],
    [Mamu-DPA Haplotype 1],
    [Mamu-DPA Haplotype 2],
    [Mamu-DPB Haplotype 1],
    [Mamu-DPB Haplotype 2],
    Comments1 AS [Lab Comments]
	FROM dbo.MhcStaging AS M
	-- select primates only from the TxBiomed colony
    INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = RIGHT(SPACE(6) + m.[Animal ID], 6)
	
	) AS P

UNPIVOT ([MHC Value] FOR Haplotype IN
  ([Mamu-A Haplotype 1],
    [Mamu-A Haplotype 2],
    [Mamu-B Haplotype 1],
    [Mamu-B Haplotype 2],
    [Mamu-DRB Haplotype 1],
    [Mamu-DRB Haplotype 2],
    [Mamu-DQA Haplotype 1],
    [Mamu-DQA Haplotype 2],
    [Mamu-DQB Haplotype 1],
    [Mamu-DQB Haplotype 2],
    [Mamu-DPA Haplotype 1],
    [Mamu-DPA Haplotype 2],
    [Mamu-DPB Haplotype 1],
    [Mamu-DPB Haplotype 2])) AS u

	WHERE LEN(u.[MHC Value]) > 0

	GO

GRANT SELECT ON labkey_etl.V_MhcData TO z_labkey;

GO
