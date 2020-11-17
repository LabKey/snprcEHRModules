SELECT
       sdc.LSID as LSID,
       sdc.Id as ID,
       sdc.Date Date,
       MAX(sdc.Value) as Values,
       sdc.EventId as EventId,
       sdc.QcState as QcState,
       sdc.AttributeName
FROM (
         SELECT LSID as LSID,
                EventData.EventId.SubjectId AS Id,
                EventData.EventId.Date,
                FloatValue AS value,
                EventId,
                EventId.QcState AS QcState,
                AttributeName
         FROM SND.DataByCategory AS v
         WHERE Category = 'Vitals'
     ) AS sdc

GROUP BY sdc.LSID, sdc.Id, sdc.Date, sdc.EventId, sdc.QcState, sdc.AttributeName

PIVOT Values by AttributeName IN ('temp', 'HR', 'RR')

order by id, date desc

