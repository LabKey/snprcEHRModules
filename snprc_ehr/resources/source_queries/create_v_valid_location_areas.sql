/*
 * Copyright (c) 2018-2019 LabKey Corporation
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

ALTER VIEW [labkey_etl].[v_valid_location_areas]
AS
    -- ==========================================================================================
    -- Author:		Scott Rouse
    -- Create date: 03/16/2018
    -- Description:	Select for valid_locationAreas.  Will replace area.tsv
    -- Changes:
    -- removed objectId not LK table
    -- Added Left trim to description to cap at 100 char
    --
    -- Does not have object_id or created, modified columna.
    -- Removed them 03.19.2018 stt
    -- 1/8/2019 added description and dateDisabled tjh
    -- ==========================================================================================

    SELECT
            CAST(vl.location AS INT) AS area,
            vl.description           AS description,
            vl.close_date            AS dateDisabled
    FROM
            dbo.valid_locations AS vl
        INNER JOIN
            (
                SELECT
                    MIN(location) AS min_location
                FROM
                    dbo.valid_locations AS vl2
                GROUP BY
                    CAST(location AS INT)
            )                   AS d
                ON vl.location = d.min_location

GO

GRANT
    SELECT
    ON labkey_etl.v_valid_location_areas
    TO
    z_labkey;