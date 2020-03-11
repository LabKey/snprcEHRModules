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

/****** Object:  UserDefinedFunction [labkey_etl].[f_get_location_with_cage_position]    Script Date: 3/15/2018 4:24:50 PM ******/

ALTER FUNCTION [labkey_etl].[f_get_location_with_cage_position] ()
-- =============================================
-- Author:		Terry Hawkins
-- Create date: 12/20/2017
-- Description:	Combines location and cage position data
-- changes:
-- 2/27/2018 - fixed issue with date range (added 1 day to account for casting) tjh
-- 3/16/2018 - fixed edge case where animal is moved to a new cage the same day it is moved to an outside location
-- 3/11/2020 - fixed objectid bug (was using cage_pos objectid instead of location objectid in several subqueries) 
-- =============================================

RETURNS @moveTable TABLE
    (	move_type	CHAR(1),
        row                INT IDENTITY(1, 1),
        id                 VARCHAR(6),
        startDate          DATETIME,
        endDate            DATETIME,
        room               NUMERIC(7, 2),
        cage               NUMERIC(7, 2),
        group_housing_flag VARCHAR(1),
        base_objectId      UNIQUEIDENTIFIER,
        objectId           VARCHAR(46),
        entry_date_tm      DATETIME,
        user_name          VARCHAR(128),
        timestamp          VARBINARY(8)
    )
AS
    BEGIN

        INSERT INTO @moveTable
            (
				move_type,
                id,
                startDate,
                endDate,
                room,
                cage,
                group_housing_flag,
                objectId,
                entry_date_tm,
                user_name,
                timestamp
            )
                    SELECT  '1',
                            l.id,
                            l.move_date_tm   AS startDate,
                            NULL             AS endDate,
                            l.location       AS room,
                            cp.cage_position AS cage,
                            vl.group_housing_flag,
                            l.object_id      AS objectId,
                            l.entry_date_tm  AS entry_date_tm,
                            l.user_name      AS user_name,
							(SELECT MAX(v) FROM (VALUES (l.timestamp), (cp.timestamp)) AS VALUE ( v )) AS timestamp
                    FROM
                            dbo.location        AS l
                        LEFT OUTER JOIN
                            dbo.valid_locations AS vl
                                ON vl.location = l.location
						-- get records where location and cage_positions match by id, and date
                        LEFT OUTER JOIN
                            dbo.cage_position   AS cp
                                ON l.id = cp.id
                                   AND CAST(cp.move_date_tm AS DATE) = CAST(l.move_date_tm AS DATE)
								   -- remove any duplicate day entries by taking only the one with the latest date/time
                                   AND cp.move_date_tm =
                                       (
                                           SELECT
                                               MAX(cp2.move_date_tm)
                                           FROM
                                               dbo.cage_position AS cp2
                                           WHERE
                                               cp2.id = cp.id
                                               AND CAST(cp2.move_date_tm AS DATE) = CAST(cp.move_date_tm AS DATE)
                                           GROUP BY
                                               id,
                                               CAST(cp2.move_date_tm AS DATE)
                                       )
                                   AND vl.group_housing_flag = 'N'


        INSERT INTO @moveTable
            (
				move_type,
                id,
                startDate,
                endDate,
                room,
                cage,
                group_housing_flag,
                objectId,
                entry_date_tm,
                user_name,
                timestamp
            )
                    -- get unmatched cage moves

                    SELECT '2',
                            cp.id,
                            cp.move_date_tm  AS startDate,
                            NULL             AS endDate,
                            l.location       AS room,
                            cp.cage_position AS cage,
                            vl.group_housing_flag,
                            l.object_id     AS objectId,
                            cp.entry_date_tm AS entry_date_tm,
                            cp.user_name     AS user_name,
                            (SELECT MAX(v) FROM (VALUES (l.timestamp), (cp.timestamp)) AS VALUE ( v )) AS timestamp
                    FROM
                            dbo.location        AS l
                        LEFT OUTER JOIN
                            dbo.valid_locations AS vl
                                ON vl.location = l.location
						-- get records where cage_position dates are within the location start and end date range, but
						-- don't equal it (ones that equal were added above)

                        INNER JOIN
                            dbo.cage_position AS cp
                                ON l.id = cp.id
                                   AND CAST(cp.move_date_tm AS DATE) > CAST(l.move_date_tm AS DATE)
                                   AND cp.move_date_tm < CAST(COALESCE(l.exit_date_tm, DATEADD(DAY, 1, GETDATE())) AS DATE)
                                   AND vl.group_housing_flag = 'N'

 INSERT INTO @moveTable
            (	move_type,
                id,
                startDate,
                endDate,
                room,
                cage,
                group_housing_flag,
                objectId,
                entry_date_tm,
                user_name,
                timestamp
            )
                    SELECT '3',
                            l.id,
                            l.move_date_tm   AS startDate,
                            NULL             AS endDate,
                            l.location       AS room,
                            cp.cage_position AS cage,
                            vl.group_housing_flag,
                            l.object_id      AS objectId,
                            l.entry_date_tm  AS entry_date_tm,
                            l.user_name      AS user_name,
							cp.timestamp AS timestamp
                    FROM
                            dbo.location        AS l
                        LEFT OUTER JOIN dbo.valid_locations AS vl ON vl.location = l.location
						-- get records where location and cage_positions match by id, and date
                        INNER JOIN dbo.cage_position   AS cp
                                ON l.id = cp.id
                                   AND cp.move_date_tm > l.move_date_tm AND cp.move_date_tm < COALESCE(l.exit_date_tm, GETDATE())
								  
								   -- remove any duplicate day entries by taking only the one with the latest date/time
                                   AND cp.move_date_tm =
                                       (
                                           SELECT
                                               MAX(cp2.move_date_tm)
                                           FROM
                                               dbo.cage_position AS cp2
                                           WHERE
                                               cp2.id = cp.id
                                               AND CAST(cp2.move_date_tm AS DATE) = CAST(cp.move_date_tm AS DATE)
                                           GROUP BY
                                               id,
                                               CAST(cp2.move_date_tm AS DATE)
                                       )
                                   AND vl.group_housing_flag = 'N'
						AND NOT exists (SELECT  1 FROM @moveTable AS m
									WHERE m.objectId = cp.object_id)

        RETURN;
    END;
