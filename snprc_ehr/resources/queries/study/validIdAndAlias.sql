
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