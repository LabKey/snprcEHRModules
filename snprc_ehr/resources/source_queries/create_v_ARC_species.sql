/*==============================================================*/
/* View: v_valid_ARC_Species                                    */
/*==============================================================*/
CREATE VIEW labkey_etl.v_ARC_Species as
    -- ====================================================================================================================
-- Object: v_valid_ARC_Species
-- Author:		Scott Rouse
-- Create date: 04/28/2020
-- Note:
--
-- ==========================================================================================

SELECT a.arc_species_code                                      AS code,
       a.common_name                                           AS CommonName,
       a.scientific_name                                       AS scientific_name,
       a.primate                                               AS PrimateFlag,
       a.entry_date_tm                                         AS modified,
       dbo.f_map_username(a.user_name)                         AS modifiedby,
       COALESCE(tc.created, a.entry_date_tm)                 AS created,
       COALESCE(tc.createdby, dbo.f_map_username(a.user_name)) AS createdBy,
       a.object_id                                             AS objectid,
       a.timestamp
FROM animal.dbo.arc_valid_species_codes a
         LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = a.object_id;
go

GRANT SELECT ON labkey_etl.v_ARC_Species TO z_labkey;
go