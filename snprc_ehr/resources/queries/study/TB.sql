SELECT
    pvt.lsid,
    pvt.Id,
    pvt.Date,
    pvt."tb_site::Value" as site,
    pvt."tb_result::Value" as result,
    pvt.EventId as EventId,
    pvt.QcState as QcState,
    pvt.CreatedBy,
    pvt.Created,
    pvt.ModifiedBy,
    pvt.Modified,
    pvt.ObjectId

FROM
( SELECT
    sdc.lsid,
    sdc.Id,
    sdc.Date,
    MAX(sdc.Value) as Value,
    sdc.EventId as EventId,
    sdc.QcState as QcState,
    sdc.AttributeName,
    sdc.CreatedBy,
    sdc.Created,
    sdc.ModifiedBy,
    sdc.Modified,
    sdc.ObjectId
FROM (
         SELECT v.lsid,
                v.SubjectId AS Id,
                v.Date,
                v.FloatValue AS value,
                v.EventId,
                v.QcState AS QcState,
                v.AttributeName,
                v.Event.CreatedBy,
                v.Event.Created,
                v.Event.ModifiedBy,
                v.Event.Modified,
                v.ObjectId
         FROM SND.DataByCategory AS v
         WHERE CategoryName = 'TB'
     ) AS sdc

GROUP BY sdc.lsid, sdc.Id, sdc.Date, sdc.EventId, sdc.QcState, sdc.AttributeName, sdc.CreatedBy, sdc.Created, sdc.ModifiedBy, sdc.Modified, sdc.ObjectId

    PIVOT Value by AttributeName IN ('tb_site', 'tb_result')
) pvt

order by id, date desc
