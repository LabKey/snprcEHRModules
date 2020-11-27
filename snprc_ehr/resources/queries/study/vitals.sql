SELECT
       sdc.lsid,
       sdc.Id as ID,
       sdc.Date Date,
       MAX(sdc.Value) as Values,
       sdc.EventId as EventId,
       sdc.QcState as QcState,
       sdc.AttributeName
FROM (
         SELECT lsid,
                SubjectId AS Id,
                Date,
                FloatValue AS value,
                EventId,
                QcState AS QcState,
                AttributeName
         FROM SND.DataByCategory AS v
         WHERE CategoryName = 'Vitals'
     ) AS sdc

GROUP BY sdc.lsid, sdc.Id, sdc.Date, sdc.EventId, sdc.QcState, sdc.AttributeName

PIVOT Values by AttributeName IN ('temp', 'HR', 'RR')

order by id, date desc

