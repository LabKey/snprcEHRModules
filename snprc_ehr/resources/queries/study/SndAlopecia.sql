SELECT sdc.lsid,
       sdc.Id,
       sdc.Date,
       group_concat(sdc.Value)             as Value,
       sdc.Event                           as EventId,
       sdc.QcState                         as QcState,
       sdc.AttributeName,
       sdc.CreatedBy,
       sdc.Created,
       sdc.ModifiedBy,
       sdc.Modified,
       sdc.ObjectId

FROM (
         SELECT v.lsid,
                v.SubjectId                                                                          AS Id,
                v.Date,
                CASE
                    WHEN v.AttributeName = 'scorer' THEN StringValue
                    WHEN v.attributeName = 'alopeciaScore' THEN cast(v.FloatValue as varchar(12)) END as Value,
                v.Event,
                v.QcState                                                                            AS QcState,
                v.AttributeName                                                                      AS AttributeName,
                v.Event.CreatedBy,
                v.Event.Created,
                v.Event.ModifiedBy,
                v.Event.Modified,
                v.ObjectId
         FROM SND.DataByCategory AS v

         WHERE v.CategoryName = 'alopecia'
     ) AS sdc

GROUP BY sdc.lsid,
         sdc.Id,
         sdc.Date,
         sdc.Event,
         sdc.QcState,
         sdc.AttributeName,
         sdc.CreatedBy,
         sdc.Created,
         sdc.ModifiedBy,
         sdc.Modified,
         sdc.ObjectId
    PIVOT Value by AttributeName IN ('alopeciaScore', 'scorer')

order by id, date desc
