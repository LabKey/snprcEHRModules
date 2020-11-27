SELECT
    sdc.LSID as LSID,
    sdc.Id as ID,
    sdc.Date Date,
    group_concat(sdc.Value) as Values,
    sdc.Event as EventId,
    sdc.QcState as QcState,
    sdc.AttributeName,
    coalesce(sdc.IACUC, 'Non-research') as IACUC,
    cast(Date as date) as dateOnly,
    0 as quantity,
    sdc.Project,
    1 as countsAgainstVolume

FROM (
         SELECT v.lsid,
                v.SubjectId as Id,
                v.Date,
                CASE WHEN v.AttributeName = 'Reason' THEN StringValue WHEN v.attributeName = 'blood_volume' THEN cast(v.FloatValue as varchar(12)) END as Value,
                v.Event,
                v.QcState,
                v.AttributeName,
                v.Event.ParentObjectId.ReferenceId.Protocol as IACUC,
                v.Event.ParentObjectId.ReferenceId as Project
         FROM SND.DataByCategory AS v

         WHERE v.CategoryName = 'Cumulative blood'
     ) AS sdc

GROUP BY sdc.LSID, sdc.Id, sdc.Date, sdc.Event, sdc.QcState, sdc.AttributeName, sdc.IACUC, sdc.Project

PIVOT Values by AttributeName IN ('blood_volume', 'Reason')

order by id, date desc
