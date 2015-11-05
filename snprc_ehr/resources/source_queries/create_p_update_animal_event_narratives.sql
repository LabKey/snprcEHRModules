/*
 * Copyright (c) 2015 LabKey Corporation
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
USE [animal]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [labkey_etl].[p_update_animal_event_narratives]
 AS
 BEGIN
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 7/13/15
-- Description:	Does an incremental update of the animal_event_narratives table
--
--  11/02/2015   Terry Hawkins   Renamed from v_delete_animal_procedures to v_delete_animal_event_narratives.
-- ==========================================================================================
CREATE TABLE #animal_event_narratives(
	[animal_event_id] [INT] NOT NULL,
	[animal_id] [VARCHAR](6) NULL,
	[event_date_tm] [DATETIME] NULL,
	[ParticipantSequenceNum] [VARCHAR](128) NULL,
	[charge_id] [INT] NULL,
	[proc_narrative] [VARCHAR](MAX) NULL,
	[objectid] [VARCHAR](128) NULL,
	[user_name] [VARCHAR](128) NULL,
	[entry_date_tm] [DATETIME] NULL,
	[ts] [BINARY](8) NULL)


  DECLARE @max_timestamp BINARY(8)

  SELECT @max_timestamp = (SELECT MAX(ts) FROM dbo.animal_event_narratives)

  -- return if there is nothing to do
  IF @max_timestamp = NULL
	RETURN 0


;  WITH CTE1 (ANIMAL_EVENT_ID, animal_id, event_date_tm, admit_id, charge_id, proc_id, parent_proc_id,
	    proc_narrative, view_order, pkg_id, order_num, LEVEL, entry_date_tm, user_name, object_id, timestamp) AS

  (

   -- anchor member definition

SELECT
	ae.ANIMAL_EVENT_ID,
	ae.animal_id AS id,
	ae.EVENT_DATE_TM,
	ae.ADMIT_ID,
	ae.CHARGE_ID,
	cp.proc_id,
	CASE WHEN cp.parent_proc_id IS NULL THEN cp.PROC_ID ELSE cp.PARENT_PROC_ID END AS parent_proc_id,
	dbo.f_decoded_narrative(cp.PROC_ID, 0) AS proc_narrative,
	cp.view_order,
	sp.PKG_ID,
	CASE WHEN cp.parent_proc_id IS NULL THEN -1 ELSE sp.order_num END AS order_num,
	1 AS LEVEL,
	ae.entry_date_tm,
	ae.USER_NAME,
	ae.OBJECT_ID,
	ae.timestamp
FROM dbo.ANIMAL_EVENTS ae
LEFT JOIN dbo.CODED_PROCS AS cp ON ae.ANIMAL_EVENT_ID = cp.ANIMAL_EVENT_ID
	AND cp.PARENT_PROC_ID IS NULL
LEFT JOIN dbo.BUDGET_ITEMS bi ON cp.BUDGET_ITEM_ID = bi.BUDGET_ITEM_ID
LEFT JOIN dbo.SUPER_PKGS sp ON bi.SUPER_PKG_ID = sp.SUPER_PKG_ID

-- select primates only from the txbiomed colony
INNER JOIN master AS m ON m.id = ae.animal_id
INNER JOIN valid_species vs ON m.species = vs.species_code
INNER JOIN arc_valid_species_codes avs ON vs.arc_species_code = avs.arc_species_code
INNER JOIN current_data AS cd ON m.id = cd.id
INNER JOIN dbo.arc_valid_species_codes AS avsc ON cd.arc_species_code = avsc.arc_species_code
WHERE avsc.primate = 'Y'

	AND ae.TIMESTAMP > @max_timestamp

UNION ALL

  -- recursive part of query
  SELECT
	c.ANIMAL_EVENT_ID,
    c.animal_id,
	c.EVENT_DATE_TM,
	c.ADMIT_ID,
	c.CHARGE_ID,
	cp.proc_id,
	cp.parent_proc_id,
	dbo.f_decoded_narrative(cp.PROC_ID, 0) AS proc_narrative,
	cp.view_order,
	sp.pkg_id,
	sp.order_num AS order_num,
	LEVEL + 1,
	c.entry_date_tm AS entry_date_tm,
	c.user_name,
	c.object_id,
	c.timestamp  AS timestamp
FROM cte1 AS c
JOIN dbo.CODED_PROCS AS cp ON cp.parent_proc_id = c.proc_id
INNER JOIN dbo.BUDGET_ITEMS bi ON cp.BUDGET_ITEM_ID = bi.BUDGET_ITEM_ID
INNER JOIN dbo.SUPER_PKGS sp ON bi.SUPER_PKG_ID = sp.SUPER_PKG_ID
),

cte_narrative (animal_event_id, animal_id, event_date_tm, charge_id, admit_id, proc_id, parent_proc_id, pkg_id,
	order_num, PROC_text, entry_date_tm, level, user_name, object_id, timestamp) AS
(


  (SELECT   c1.animal_event_id, c1.animal_id, c1.event_date_tm, c1.charge_id, c1.admit_id, c1.proc_id, c1.parent_proc_id,
			c1.pkg_id, c1.order_num,
				(
					SELECT CASE WHEN level = 1 --c.parent_proc_id = c.proc_id
						THEN '**' +  -- SPACE(level*2) +
									dbo.f_format_narrative(LTRIM(RTRIM(c.proc_narrative)), 80 - LEVEL*2 , LEVEL * 2)
						ELSE '--' +
							dbo.f_format_narrative( LTRIM(RTRIM(c.proc_narrative)), 80 - LEVEL*2 , LEVEL * 2)
						END +
							' ('+ CAST(c.pkg_id AS VARCHAR) + ')' +' **NEWLINE**'
					FROM  cte1 AS c
					WHERE c.animal_event_id = c1.animal_event_id
					ORDER BY c.view_order
					FOR XML PATH('')				-- generates a concatenation of result set (for an xml doc)
				),
				 c1.entry_date_tm, level, c1.user_name, c1.object_id, c1.timestamp
				FROM cte1 AS c1
				--WHERE c1.animal_id = @animal_id
				WHERE c1.LEVEL = 1)


  )


  INSERT INTO #animal_event_narratives
          ( animal_event_id ,
            animal_id ,
            event_date_tm ,
            ParticipantSequenceNum ,
            charge_id ,
            proc_narrative ,
            objectid ,
            user_name ,
            entry_date_tm ,
            ts
          )

 SELECT  DISTINCT c.animal_event_id AS animal_event_id,
	c.animal_id AS animal_id,
	c.event_date_tm AS event_date_tm,
	LTRIM(RTRIM(c.animal_id)) + '/'+CAST(c.animal_event_id AS VARCHAR(128)) AS ParticipantSequenceNum,
	c.charge_id AS charge_id,

	REPLACE(
		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(c.proc_text,
					'**NEWLINE**', CHAR(13)+CHAR(10) ),
					'&#x0D;', CHAR(13)+CHAR(10)),
				 '**TAB**', SPACE(4)),
				'&gt;', '>'),
		 '&lt;', '<'),
	 '&amp;', '&')

	+
	CASE WHEN pn.proc_narrative IS NULL THEN '' ELSE
		CHAR(13)+CHAR(10) +
		'Procedure Notes:' + CHAR(13)+CHAR(10) +   pn.proc_narrative END +
	CASE WHEN t.drug IS NULL THEN ' ' ELSE
		CHAR(13)+CHAR(10) +
		'Therapy details:' + CHAR(13)+CHAR(10) +  CAST (t.dose AS VARCHAR)  + ' ' +
				CAST(t.units AS VARCHAR) + ' ' + t.drug + ' ' + t.route + ' ' +
				t.frequency + '.  Started on ' +
				CAST(CAST(c.event_date_tm AS DATE) AS VARCHAR)  + ' ' +
				'for ' + t.dx + '.' +
				-----
					CASE WHEN T.stop_date IS NULL THEN '' ELSE
						' Therapy ended on ' +
						CAST(CAST(t.stop_date AS DATE) AS VARCHAR) +
						' with a status of ' + t.resolution + '.'
					END
			    ---
				END
		AS proc_narrative,

	c.object_id AS objectid,
	c.user_name AS user_name,
	c.entry_date_tm,
    c.timestamp



	FROM cte_narrative AS c
	LEFT OUTER JOIN  proc_notes AS pn ON pn.ANIMAL_EVENT_ID = c.ANIMAL_EVENT_ID
	LEFT OUTER JOIN therapy AS t ON t.animal_event_id = c.animal_event_id
	INNER JOIN dbo.ANIMAL_EVENTS AS ae ON c.animal_event_id = ae.ANIMAL_EVENT_ID
	LEFT OUTER JOIN dbo.clinic AS c1 ON c1.admit_id = ae.ADMIT_ID
	AND c.ANIMAL_EVENT_ID NOT IN (SELECT aae.animal_event_id FROM audit.AUDIT_ANIMAL_EVENTS AS aae
										WHERE aae.ANIMAL_EVENT_ID = ae.ANIMAL_EVENT_ID
										  AND aae.AUDIT_ACTION = 'D')




  -- delete rows that have been updated
  DELETE ap
	FROM dbo.animal_event_narratives AS ap
	WHERE ap.animal_event_id IN
		(SELECT DISTINCT aae.ANIMAL_EVENT_ID
			FROM dbo.animal_event_narratives AS ap
			JOIN audit.audit_animal_events AS aae ON aae.ANIMAL_EVENT_ID = ap.animal_event_id
			WHERE aae.AUDIT_TIMESTAMP > @max_timestamp
			AND aae.AUDIT_ACTION = 'UI')

  -- insert the new rows
  INSERT INTO dbo.animal_event_narratives
          ( animal_event_id ,
            animal_id ,
            event_date_tm ,
            ParticipantSequenceNum ,
            charge_id ,
            proc_narrative ,
            objectid ,
            user_name ,
            entry_date_tm ,
            ts
          )
	SELECT animal_event_id ,
            animal_id ,
            event_date_tm ,
            ParticipantSequenceNum ,
            charge_id ,
            proc_narrative ,
            objectid ,
            user_name ,
            entry_date_tm ,
            ts
			FROM #animal_event_narratives

	RETURN 0

	END

	GRANT EXEC ON [labkey_etl].[p_update_animal_event_narratives] TO z_labkey
	go