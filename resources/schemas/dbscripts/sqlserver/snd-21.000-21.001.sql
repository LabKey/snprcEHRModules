UPDATE exp.PropertyValidator SET TypeURI = 'urn:lsid:labkey.com:PropertyValidator:textlength'
WHERE TypeURI = 'urn:lsid:labkey.com:PropertyValidator:length'
  AND PropertyId IN (
    SELECT PropertyId
    FROM exp.PropertyDescriptor
    WHERE PropertyURI LIKE '%:package-snd%Package%'
  )