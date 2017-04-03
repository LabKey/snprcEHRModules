ALTER VIEW [labkey_etl].[V_ANIMAL_GROUP_CATEGORIES] AS
-- =========================================================================================
-- Object: v_animal_group_categories
-- Author:		Terry Hawkins
-- Create date: 2/20/2017
--
-- ==========================================================================================


SELECT
agc.category_code ,
agc.description ,
agc.comment ,
agc.displayable ,
agc.species ,
agc.sex ,
agc.enforce_exclusivity ,
agc.allow_future_date ,
agc.sort_order ,
agc.object_id AS objectid,
agc.entry_date_tm                                      AS modified,
dbo.f_map_username(agc.user_name)                      AS modifiedby,
tc.created                                            AS created,
tc.createdby                                          AS createdby,
agc.timestamp 

FROM dbo.animal_group_categories AS agc
LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = agc.object_id
  

GO

GRANT SELECT ON labkey_etl.V_ANIMAL_GROUP_CATEGORIES TO z_labkey
GRANT SELECT ON dbo.animal_group_categories TO z_labkey

GO