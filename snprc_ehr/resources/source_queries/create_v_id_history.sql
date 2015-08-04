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
/* View: V_id_history                                           */
/*==============================================================*/
CREATE VIEW [labkey_etl].[V_ID_HISTORY] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/1/2015
-- Description:	Selects the ETL records for LabKey study.idHistory dataset
-- Changes:
--
--
-- ==========================================================================================
SELECT ih.sfbr_id AS id,
ih.id_date AS id_date,
ISNULL(ih.id_date, CAST('01/01/1901 00:00' AS DATETIME)) AS date,
ih.id_value AS value,
ih.id_type AS id_type,
vi.institution_name AS source_name,
comment AS comment,
object_id AS objectid,
ih.user_name,
ih.entry_date_tm

 FROM id_history AS ih
JOIN dbo.valid_institutions AS vi ON vi.institution_id = ih.institution_id
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ih.sfbr_id

GO 

GRANT SELECT ON Labkey_etl.V_ID_HISTORY TO z_labkey 

GO
