ALTER VIEW [labkey_etl].[v_snd_ProjectItems]
AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 09/27/2017
-- Description:	selects the ProjectItems (budget_items) data for the SND integration to snprc_ehr
-- Note:
--
-- Changes:
--
-- ==========================================================================================


SELECT  bi.BUDGET_ITEM_ID AS ProjectItemId ,
        b.OBJECT_ID AS ParentObjectId ,
        bi.SUPER_PKG_ID AS SuperPkgId ,
        CASE WHEN bi.DISPLAYABLE_FLAG = 'Y' THEN 1 ELSE 0 END AS Active ,
        bi.OBJECT_ID AS objectid ,
        bi.ENTRY_DATE_TM AS modified ,
        dbo.f_map_username(bi.USER_NAME) AS modifiedby ,
        tc.created AS created ,
        tc.createdby AS createdby ,
        bi.TIMESTAMP AS timestamp
FROM    dbo.BUDGET_ITEMS AS bi
        INNER JOIN dbo.BUDGETS AS b ON bi.BUDGET_ID = b.BUDGET_ID AND bi.REVISION_NUM = b.REVISION_NUM
		INNER JOIN dbo.super_pkgs AS sp ON bi.super_pkg_id = sp.super_pkg_id AND sp.parent_pkg_id IS null
        LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = bi.OBJECT_ID;


GO
GRANT SELECT ON [labkey_etl].[v_snd_ProjectItems] TO z_labkey;

GO

