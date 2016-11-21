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

/****** Object:  View [labkey_etl].[V_ARRIVAL]    Script Date: 4/1/2015 10:29:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================*/
/* View: V_ARRIVAL                                         */
/*==============================================================*/
ALTER VIEW [labkey_etl].[V_ARRIVAL] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/3/2015
-- Description:	Selects the ETL records for LabKey study.arrival dataset
-- Changes:
-- 11/10/2016  added modified, modifiedby, created, and createdby columns tjh
--
--
-- ==========================================================================================

SELECT
  ad.id                            AS id,
  ad.acq_date_tm                   AS date,
  ad.acq_code                      AS acquisitionType,
  m.dam_id                         AS dam,
  m.sex                            AS gender,
  m.species                        AS species,
  m.sire_id                        AS sire,
  m.birth_date                     AS birth,
  CASE WHEN m.bd_status <> 0
    THEN 'True'
  ELSE 'False' END                 AS estimated,
  ad.object_id                     AS objectid,
  ad.entry_date_tm                 AS modified,
  dbo.f_map_username(ad.user_name) AS modifiedby,
  tc.created                       AS created,
  tc.createdby                     AS createdby,
  ad.timestamp
FROM dbo.acq_disp AS ad
  INNER JOIN master AS m ON m.id = ad.id
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = ad.object_id
  -- select primates only from the TxBiomed colony
  INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ad.id

GO

GRANT SELECT ON Labkey_etl.v_arrival TO z_labkey
GO

