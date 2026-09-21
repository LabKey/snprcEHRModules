/*
 * Copyright (c) 2026 LabKey Corporation
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
/* View: V_DELETE_BIOCONTAINMENTOBSERVATIONS                    */
/*==============================================================*/
-- Source table: audit.BiocontainmentObservation,
CREATE VIEW [labkey_etl].[v_delete_BiocontainmentObservations] as
-- ==========================================================================================
-- Author:     Ram
-- Create date: 09/10/26
-- Description: Selects deleted Biocontainment Observations rows from CAMP's audit.BiocontainmentObservation
--              for delete-tracking in the CAMP to TAC import ETL (resources/etls/BiocontainmentObservations.xml)
-- ==========================================================================================
SELECT ao.ObjectId as object_id, ao.audit_date_tm
FROM audit.BiocontainmentObservation ao

       -- select primates only from the TxBiomed colony
       INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = ao.id
WHERE ao.audit_action = 'D' AND ao.ObjectId IS NOT NULL;

 go

GRANT SELECT on labkey_etl.[V_DELETE_BIOCONTAINMENTOBSERVATIONS] to z_labkey;
GRANT SELECT ON audit.BiocontainmentObservation TO z_labkey;


  go