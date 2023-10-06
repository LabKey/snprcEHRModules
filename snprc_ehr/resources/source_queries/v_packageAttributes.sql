ALTER VIEW [labkey_etl].[v_packageAttributes] AS
(
SELECT pa.PKG_ID AS pkgId,
       pa.ATTRIB_ID AS AttributeId,
       pa.ATTRIB_KEY AS AttributeName,
	   'snd' AS LookupSchema,
       pa.LOOKUP_KEY AS LookupQuery,
	   CASE WHEN pa.DATA_TYPE = 'String' THEN 'http://www.w3.org/2001/XMLSchema#string' 
			WHEN pa.DATA_TYPE = 'Numeric' THEN 'http://www.w3.org/2001/XMLSchema#int' 
			ELSE 'http://www.w3.org/2001/XMLSchema#double' END AS RangerURI,
       COALESCE(pa.LABEL,pa.ATTRIB_KEY) AS Label,
	   CASE WHEN (pa.[MAX] IS NOT NULL AND pa.[MIN] IS NOT NULL) THEN '~lte='+LTRIM(RTRIM(pa.[MAX]))+'&~gte='+LTRIM(RTRIM(pa.[MIN]))
	        WHEN (pa.[MAX] IS NOT NULL AND pa.[MIN] IS NULL) THEN '~lte='+LTRIM(RTRIM(pa.[MAX]))
			WHEN (pa.[MIN] IS NOT NULL AND pa.[MAX] IS NULL) THEN '~gte='+LTRIM(RTRIM(pa.[MIN]))
			ELSE NULL
			END AS ValidatorExpression,
       COALESCE(pa.ORDER_NUM, 0) AS SortOrder,
       CASE WHEN pa.IS_REQUIRED = 'Y' THEN 1 ELSE 0 END AS Required,
       pa.DEFAULT_VALUE DefaultValue,
       pa.ALTERNATE_TEXT AS AlternateText,			
	   tc.created AS Created,
	   dbo.f_map_username(TC.createdBy) AS CreatedBy,
	   pa.ENTRY_DATE_TM AS Modified,
	   dbo.f_map_username(pa.USER_NAME) AS ModifiedBy,
       pa.OBJECT_ID AS ObjectId
FROM dbo.PKG_ATTRIBS AS pa
INNER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = pa.OBJECT_ID
)
GO 

GRANT SELECT ON Labkey_etl.v_packageAttributes TO z_labkey
GO