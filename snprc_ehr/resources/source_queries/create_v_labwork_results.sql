/*
 * Copyright (c) 2016 LabKey Corporation
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

/****** Object:  View [labkey_etl].[v_labwork_results]    Script Date: 2/5/2015 8:51:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/4/2016
-- Description:	Merged surveillance, hematology, and biochemistry into a single view for the 
--                  labkey ETL.
--
-- Changes:
-- 11/11/2016 Major code cleanup tjh
-- ==========================================================================================

ALTER VIEW [labkey_etl].[v_labwork_results] AS


SELECT * FROM labkey_etl.V_LABWORK_CHEMISTRY_RESULTS
UNION
SELECT * FROM labkey_etl.V_LABWORK_HEMATOLOGY_RESULTS
UNION
SELECT * FROM labkey_etl.V_LABWORK_SURVEILLANCE_RESULTS

go

GRANT SELECT ON [labkey_etl].[v_labwork_results]  TO z_labkey
GRANT SELECT ON dbo.CLINICAL_PATH_PROC_ID_LOOKUP TO z_labkey
grant SELECT on [labkey_etl].[v_labwork_results] to z_camp_base

GO