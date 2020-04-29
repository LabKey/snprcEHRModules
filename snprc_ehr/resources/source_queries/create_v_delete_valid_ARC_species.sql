
-- ##############    NOT NEEDED FOR TRUNCATE ETL ##########################

/*
CREATE VIEW labkey_etl.v_delete_valid_ARC_species AS
-- ==========================================================================================
-- Author:		Scott Rouse
-- Create date: 04/28/2020
-- Description:	Selects the valid_ for LabKey snprc_ehr.valid_diet dataset for deletions
-- Note: During COVID1984
--
-- Changes:
--
-- ==========================================================================================


SELECT ad.object_id,
       ad.audit_date_tm


FROM audit_arc_valid_species_codes AS ad

WHERE ad.audit_action = 'D' AND ad.object_id IS NOT NULL



    GO


GRANT SELECT on labkey_etl.v_delete_valid_ARC_species to z_labkey
GRANT SELECT ON audit_arc_valid_species_codes TO z_labkey
*/