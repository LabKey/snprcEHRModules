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

ALTER VIEW [labkey_etl].[v_valid_locations]
AS
    -- ==========================================================================================
    -- Author:		Scott Rouse
    -- Create date: 03/14/2018
    -- Description:	Select for valid_locations.  Will replace rooms.tsv
    -- Changes:
    -- removed objectId not LK table
    -- Added Left trim to description to cap at 100 char
    -- 03.21.2018
    -- Added close_date as dateDisabled.
    --	Because SNPRC locations are date bound, has the potential for multiple rows for a single location.
    --    None currently exists.  Not addressing at this time. srr

    --
    -- Note:  Had to add alt Key to XML.  Do not know why. srr
    -- ==========================================================================================

    SELECT
            CAST(vl.location AS VARCHAR(100)) AS room,
            LEFT(vl.description, 100)         AS [building],
            CAST(vl.location AS INT)          AS [area],
            vl.max_num_cages                  AS [maxCages],
            vl.location * 100                 AS [sort_order],
            vl.close_date                     AS [dateDisabled],
            -- vl.object_id AS [objectid],
            vl.entry_date_tm                  AS [modified],
            dbo.f_map_username(vl.user_name)  AS [modifiedby],
            tc.created                        AS created,
            tc.createdby                      AS createdby,
            vl.timestamp
    FROM
            animal.dbo.valid_locations vl
        INNER JOIN
            dbo.TAC_COLUMNS            AS tc
                ON tc.object_id = vl.object_id

GO

GRANT
    SELECT
    ON labkey_etl.v_valid_locations
    TO
    z_labkey;
GO
