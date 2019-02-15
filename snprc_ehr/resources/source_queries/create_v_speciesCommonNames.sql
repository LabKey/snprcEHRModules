ALTER VIEW [labkey_etl].[v_speciesCommonNames]
AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 2/14/2019
-- Description:	returns a list of distinct common names for two-character species codes
-- Changes:
--
-- ==========================================================================================
SELECT DISTINCT common_name AS value
FROM dbo.arc_valid_species_codes
GO


GRANT SELECT ON labkey_etl.v_speciesCommonNames TO z_labkey;
GO