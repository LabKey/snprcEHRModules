USE [animal]
GO

ALTER VIEW [labkey_etl].[v_valid_diet] AS
-- ====================================================================================================================
-- Object: v_valid_diet
-- Author:		Scott Rouse
-- Create date: 03/05/2019
-- Changes:
--
-- 03/11/2019  srr added tid as DietId
-- 03/19/2019  srr refactored DietId to DietCode to better agree with naming elsewhere
-- ==========================================================================================

SELECT
  vd.diet							    AS Diet,
  vd.arc_species_code		AS ARCSpeciesCode,
  vd.start_date						AS StartDate,
  vd.stop_date						AS StopDate,
  vd.snomed_code					AS SnomedCode,
  vd.tid                 AS DietCode,
  vd.object_id						AS objectid,
  vd.entry_date_tm					AS modified,
  dbo.f_map_username(vd.user_name)	AS modifiedby,
  tc.created						AS created,
  tc.createdby						AS createdby,
  vd.timestamp
FROM dbo.valid_diet AS vd
       LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = vd.object_id

  GO


GRANT SELECT ON labkey_etl.v_valid_diet TO z_labkey

  GO


  