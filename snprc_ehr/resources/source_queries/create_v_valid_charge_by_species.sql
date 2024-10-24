/*
 * Copyright (c) 2017-2018 LabKey Corporation
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
ALTER VIEW [labkey_etl].[v_valid_charge_by_species]
AS
    -- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 12/14/2017
-- Description:	View provides the data for snprc_ehr.ValidChargeBySpecies table
-- Changes:
--
-- 10/22/2019  Added logic to transform behavioral project purpose
-- 02/15/2020  Added startDate and stopDate columns tjh
-- ==========================================================================================

SELECT  ca.charge_id AS Project ,
        v.arc_species_code AS Species ,
        case when v.charge_id between 6000 and 6999 then 'B' else v.purpose end AS Purpose ,
        ca.start_date AS startDate,
        ca.stop_date stopDate,
        v.object_id AS ObjectId ,
        v.entry_date_tm AS modified ,
        dbo.f_map_username(v.user_name) AS modifiedby ,
        COALESCE(tc.created, v.entry_date_tm) AS created ,
        COALESCE(tc.createdby, dbo.f_map_username(v.user_name)) AS createdby ,
        v.timestamp AS timestamp
FROM    dbo.valid_charge_by_species AS v
            INNER JOIN dbo.charge_account AS ca ON ca.charge_id = v.charge_id
            LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = v.object_id
WHERE v.purpose <> 'NC'
GO


GRANT SELECT ON labkey_etl.v_valid_charge_by_species TO z_labkey;

GO