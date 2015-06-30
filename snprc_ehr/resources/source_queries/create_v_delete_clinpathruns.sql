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

/****** Object:  View [dbo].[Labkey_etl.v_delete_clinPathRuns]    Script Date: 6/26/2015 2:02:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW Labkey_etl.v_delete_clinPathRuns AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 6/26/2015
-- Description:	Selects the ETL records for LabKey study.clinPathRuns dataset for deletes
-- Changes:
--
--
-- ==========================================================================================
SELECT log.MESSAGE_ID,
log.ENTRY_DATE_TM

FROM dbo.HL7_IMPORT_LOG AS log
WHERE log.RESULT_STATUS = 'X' -- 'X' = cancelled orders
  

GO

GRANT SELECT ON Labkey_etl.v_delete_clinPathRuns TO z_labkey
GRANT SELECT ON dbo.HL7_IMPORT_LOG TO z_labkey
  
GO