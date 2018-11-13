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

CREATE VIEW [labkey_etl].[V_FLAG_VALUES] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 3/28/2016
-- Description:	Used as source for the flag_values ETL
-- Note:
--
-- Changes:
--
-- ==========================================================================================

SELECT f.category ,
       f.value ,
       f.code ,
       f.description ,
       f.objectid ,
       f.datedisabled,
       f.entry_date_tm,
       f.timestamp
FROM labkey_etl.flag_values AS f


GO
grant SELECT on [labkey_etl].[v_flag_values] to z_labkey

go

