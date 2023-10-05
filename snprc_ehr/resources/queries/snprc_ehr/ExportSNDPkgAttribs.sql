/******************************************************************
  Query will feed the ETL to move pkg attrib data from TAC to CAMP.
 *****************************************************************/
SELECT  pa.PkgId as PKG_ID,
        pa.Name as ATTRIB_KEY,
        --pa.pkgIdAttribKey,
        pa.LookupQuery as LOOKUP_KEY,
        CASE WHEN pa.RangeURI = 'http://www.w3.org/2001/XMLSchema#int' THEN 'Numeric'
             WHEN pa.RangeURI = 'http://www.w3.org/2001/XMLSchema#double' THEN 'Decimal'
             ELSE 'String'
        END as DATA_TYPE,
        CASE WHEN (pa.validatorName LIKE '%Range' AND  validatorExpression LIKE '%~gte=%')
                 THEN substring(pa.validatorExpression + '&',
                      charindex('~gte=', pa.validatorExpression) + 5, -- Stert position
                      (charindex('&', pa.validatorExpression + '&', charindex('~gte=', pa.validatorExpression)) - charindex('~gte=', pa.validatorExpression) ) - 5 -- Length
                )
             ELSE NULL
            END as "MIN",
         CASE WHEN (pa.validatorName LIKE '%Range' AND  validatorExpression LIKE '%~lte=%')
                THEN substring(pa.validatorExpression + '&',
                     charindex('~lte=', pa.validatorExpression) + 5, -- Stert position
                     (charindex('&', pa.validatorExpression + '&', charindex('~lte=', pa.validatorExpression)) - charindex('~lte=', pa.validatorExpression) ) - 5 -- Length
                   )
                ELSE NULL
         END as "MAX",        pa.defaultValue as DEFAULT_VALUE,
         COALESCE(pa.Label, pa.Name)  as LABEL,
        --pa.validatorExpression+'&' as ValidatorExpression,
        --NULL as ORDER_NUM,
        CASE WHEN pa.REQUIRED = true THEN 'Y' ELSE 'N' END as IS_REQUIRED,
        pa.RedactedText as ALTERNATE_TEXT,
        --NULL as OBJECT_ID,
        coalesce(pa.pkgModifiedBy.DisplayName, 'dbo') as USER_NAME,
        pa.pkgModified as ENTRY_DATE_TM,
        pa.propertyId
FROM snd.PackageAttribute AS pa


