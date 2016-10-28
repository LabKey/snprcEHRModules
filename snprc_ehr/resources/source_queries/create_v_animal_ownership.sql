/*
 * Copyright (c) 2015-2016 LabKey Corporation
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

CREATE VIEW [labkey_etl].[V_ANIMAL_OWNERSHIP] as
-- ====================================================================================================================
-- Object: v_animal_ownership
-- Author:		Terry Hawkins
-- Create date: 5/25/2016
--
-- ==========================================================================================


SELECT
a.id,
a.assign_date as date,
a.owner_institution_id as owner_institution,
a.institution_acquired_from_id as institution_acquired_from,
a.end_date as enddate,
a.object_id as objectid,
a.user_name as modifiedby,
a.entry_date_tm modified,
a.timestamp

from dbo.animal_ownership a
-- select primates only from the TxBiomed colony
INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = a.ID

go

grant SELECT on labkey_etl.V_ANIMAL_OWNERSHIP to z_labkey

go