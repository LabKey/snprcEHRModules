ALTER  VIEW [labkey_etl].[v_valid_species] AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 11/23/2015
-- Description:	Selects the ETL records for LabKey ehr_lookups.species dataset
-- Changes:
--
--
-- ==========================================================================================

SELECT vs.tid AS rowid,
	   vs.species_code ,
       vs.common_name AS common,
       vs.scientific_name,
       vs.arc_species_code,
       avs.common_name AS arc_common_name,
       avs.scientific_name AS arc_scientific_name,
	   vs.object_id AS objectId,
       vs.user_name ,
       vs.entry_date_tm,
       (SELECT Max(v)
		   FROM (VALUES (vs.timestamp), (avs.timestamp) ) AS VALUE (v) ) AS timestamp


FROM dbo.valid_species AS vs
INNER JOIN dbo.arc_valid_species_codes AS avs ON avs.arc_species_code = vs.arc_species_code AND avs.primate = 'Y'

GO

GRANT SELECT ON Labkey_etl.v_valid_species TO z_labkey
GO

