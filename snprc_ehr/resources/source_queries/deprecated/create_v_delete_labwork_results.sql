/*
 * Copyright (c) 2015-2019 LabKey Corporation
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

/****** Object:  View [dbo].[Labkey_etl.v_delete_labwork_results]    Script Date: 6/26/2015 2:02:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW Labkey_etl.v_delete_labwork_results AS
  -- ==========================================================================================
  -- Author:		Terry Hawkins
  -- Create date: 6/26/2015
  -- Description:	Selects the ETL records for LabKey study.labwork_results dataset for deletes
  -- Changes:
  -- 12/17/2018 changed query delete source
  --
  -- ==========================================================================================
  SELECT obr.message_id AS objectid, obr.entry_date_tm
  FROM dbo.CLINICAL_PATH_OBR AS obr -- select primates only from the TxBiomed colony
         INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = obr.ANIMAL_ID

  WHERE obr.RESULT_STATUS IN ('X') -- 'X' = cancelled order


GO

GRANT SELECT ON Labkey_etl.v_delete_labwork_results TO z_labkey
GRANT SELECT ON dbo.HL7_IMPORT_LOG TO z_labkey

GO