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

/****** Object:  View [labkey_etl].[v_clinical_admissions]    Script Date: 8/14/2015 8:08:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [labkey_etl].[v_valid_vets] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 8/5/2016
-- Description:	Selects the valid vets
-- Note:
--
--
-- ==========================================================================================


SELECT v.tid AS vetId,
	   v.vet_name AS displayName,
	   v.email_address as emailAddress,
	   case when v.status = 'A' then 'Active' else 'Inactive' end AS status,
	   v.user_name AS user_name,
	   v.entry_date_tm AS entry_date_tm,
	   v.object_id AS objectid,
	   v.timestamp AS timestamp



FROM dbo.valid_vet AS v

GO


grant SELECT on [labkey_etl].[v_valid_vets] to z_labkey

go
