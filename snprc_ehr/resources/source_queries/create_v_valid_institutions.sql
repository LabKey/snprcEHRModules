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
CREATE VIEW [labkey_etl].[V_VALID_INSTITUTIONS] AS
-- ====================================================================================================================
-- Object: v_valid_institutions
-- Author:		Terry Hawkins
-- Create date: 5/25/2016
-- ==========================================================================================

SELECT vi.institution_id ,
       vi.institution_name ,
       vi.short_name ,
       vi.city ,
       vi.state ,
       vi.affiliate ,
       vi.web as web_site,
       vi.user_name as modifiedby,
       vi.entry_date_tm as modified,
       vi.object_id as objectid,
       vi.timestamp
	   FROM dbo.valid_institutions AS vi

GO

grant SELECT on labkey_etl.V_VALID_INSTITUTIONS to z_labkey

go