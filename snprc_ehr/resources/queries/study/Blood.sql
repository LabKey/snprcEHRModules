SELECT
    sdc.LSID as LSID,
    sdc.Id as ID,
    sdc.Date Date,
    group_concat(sdc.Value) as Values,
    sdc.EventId as EventId,
    sdc.QcState as QcState,
    sdc.AttributeName,
    coalesce(sdc.IACUC, 'Non-research') as IACUC,
    cast(Date as date) as dateOnly,
    0 as quantity,
    sdc.Project,
    1 as countsAgainstVolume

FROM (
         SELECT v.LSID as LSID,
                v.EventData.EventId.SubjectId AS Id,
                v.EventData.EventId.Date,
                CASE WHEN v.AttributeName = 'Reason' THEN StringValue WHEN v.attributeName = 'blood_volume' THEN cast(v.FloatValue as varchar(12)) END as Value,
                v.EventId,
                v.EventId.QcState AS QcState,
                v.AttributeName,
                v.EventId.ParentObjectId.ReferenceId.Protocol as IACUC,
                v.EventId.ParentObjectId.ReferenceId as Project
         FROM SND.DataByCategory AS v

         WHERE v.Category = 'Cumulative blood'
     ) AS sdc

GROUP BY sdc.LSID, sdc.Id, sdc.Date, sdc.EventId, sdc.QcState, sdc.AttributeName, sdc.IACUC, sdc.Project

PIVOT Values by AttributeName IN ('blood_volume', 'Reason')

order by id, date desc
