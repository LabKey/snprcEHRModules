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

/* Create a list of valid ID to alias mappings using ID history and demographics.
*
*  This contains a list of animal ID's that are in demographics and any valid aliases
*  they may have with the exception of any alias that matches a valid animal ID.
*/

SELECT
Id,
value AS alias
FROM (
  -- Get all rows in ID history where alias does not equal an actual animal ID
  SELECT
  inDem.Id,
  inDem.value
  FROM (
    -- Get all rows in ID history with matching animal in demographics
    SELECT hist.Id,
    ltrim(rtrim(hist.value)) AS value
    FROM idHistory AS hist
    LEFT JOIN
    demographics AS dem
    ON dem.Id = hist.Id
    WHERE dem.Id IS NOT NULL)
  AS inDem
  LEFT JOIN demographics AS demo
  ON demo.Id = inDem.value
  WHERE demo.Id IS NULL)
UNION
SELECT
Id,
Id AS alias
FROM demographics