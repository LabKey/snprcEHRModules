ALTER VIEW [labkey_etl].[v_sndPackageAttributes] AS
(
    SELECT pa.PKG_ID AS pkgId,
           pa.ATTRIB_ID AS AttributeId,
           pa.ATTRIB_KEY AS AttributeName,
           CASE WHEN pa.LOOKUP_KEY IS NOT NULL THEN 'snd' ELSE NULL END AS LookupSchema,
           pa.LOOKUP_KEY AS LookupQuery,
           CASE WHEN pa.LOOKUP_KEY IS NOT NULL THEN 'http://www.w3.org/2001/XMLSchema#int' -- lookups use rowid in LK
                WHEN pa.DATA_TYPE = 'string' THEN 'http://www.w3.org/2001/XMLSchema#string'
                WHEN COALESCE(fix.DATA_TYPE, pa.DATA_TYPE) = 'numeric' THEN 'http://www.w3.org/2001/XMLSchema#int'
                WHEN COALESCE(fix.DATA_TYPE, pa.DATA_TYPE) = 'double' THEN 'http://www.w3.org/2001/XMLSchema#double'
                ELSE 'http://www.w3.org/2001/XMLSchema#double' END AS RangeURI,
           CASE WHEN LTRIM(RTRIM(pa.LABEL)) = ''  or pa.Label IS NULL THEN pa.ATTRIB_KEY ELSE pa.LABEL END AS Label,
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
    LEFT JOIN dbo.v_sndFixNumericAttributes as fix on pa.ATTRIB_ID = fix.ATTRIB_ID
    INNER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = pa.OBJECT_ID
)
GO 

GRANT SELECT ON Labkey_etl.v_sndPackageAttributes TO z_labkey
GO