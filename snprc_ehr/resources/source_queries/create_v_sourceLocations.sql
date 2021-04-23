ALTER VIEW [labkey_etl].[v_sourceLocations]
AS
-- ==========================================================================================
-- Author:		Terry Hawkins
-- Create date: 4/1/2021
-- Description:	returns a list of places from which an animal can be acquired.
-- NOTE: these are regular location codes
-- Changes:
--
-- ==========================================================================================

SELECT vl.location AS code,
	   LTRIM(RTRIM([dbo].[f_split](vl.description, ',', 1))) AS meaning,
	   LTRIM(RTRIM([dbo].[f_split](vl.description, ',', 2))) AS SourceCity,
	   LTRIM(RTRIM([dbo].[f_split]([dbo].[f_split](vl.description, ',', 3),'(', 1))) AS SourceState,
	   s.country AS SourceCountry,
	   LTRIM(RTRIM([dbo].[f_split]([dbo].[f_split](vl.description, '(', 2), ')', 1))) AS description
FROM dbo.valid_locations AS vl
LEFT OUTER JOIN dbo.CountryCodeLookup AS s ON s.code = LTRIM(RTRIM([dbo].[f_split]([dbo].[f_split](vl.description, ',', 3),'(', 1)))
WHERE vl.location >= 800 AND vl.description NOT LIKE '%mono birth%'
GO

GRANT SELECT ON labkey_etl.v_sourceLocations TO z_labkey;
GO