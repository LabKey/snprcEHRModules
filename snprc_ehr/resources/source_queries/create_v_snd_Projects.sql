CREATE VIEW [labkey_etl].[v_snd_Projects] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 09/27/2017
-- Description:	selects the package_category data for the SND integration to snprc_ehr
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT
  b.budget_id AS ProjectId,
  b.revision_num AS RevisionNum,
  b.charge_id AS referenceId,
  b.start_date_tm AS StartDate,
  b.end_date_tm AS EndDate,
  b.description as Description,
  b.object_id                     AS objectid,
  b.entry_date_tm                 AS modified,
  dbo.f_map_username(b.user_name) AS modifiedby,
  tc.created                        AS created,
  tc.createdby                      AS createdby,
  b.timestamp                     AS timestamp
FROM dbo.budgets AS b
  LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = b.object_id

GO
GRANT SELECT ON [labkey_etl].[v_snd_Projects] TO z_labkey

GO

