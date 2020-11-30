SELECT
    sdc.Id as ID,
    sdc.Date Date,
    group_concat(sdc.Value) as Values,
    sdc.EventId as EventId,
    sdc.QcState as QcState,
    sdc.AttributeName,
    coalesce(sdc.IACUC, 'Non-research') as IACUC,
    cast(Date as date) as dateOnly,
    sdc.Project,
    1 as countsAgainstVolume,
    sdc.CreatedBy,
    sdc.Created,
    sdc.ModifiedBy,
    sdc.Modified,
    sdc.ObjectId

FROM (
         SELECT
                v.EventData.EventId.SubjectId AS Id,
                v.EventData.EventId.Date,
                CASE WHEN v.AttributeName = 'Reason' THEN StringValue WHEN v.attributeName = 'blood_volume' THEN cast(v.FloatValue as varchar(12)) END as Value,
                v.EventId,
                v.EventId.QcState AS QcState,
                v.AttributeName,
                v.EventId.ParentObjectId.ReferenceId.Protocol as IACUC,
                v.EventId.ParentObjectId.ReferenceId as Project,
                v.CreatedBy,
                v.Created,
                v.ModifiedBy,
                v.Modified,
                v.ObjectId
         FROM SND.DataByCategory AS v

         WHERE v.Category = 'Cumulative blood'
     ) AS sdc

GROUP BY sdc.Id,
         sdc.Date,
         sdc.EventId,
         sdc.QcState,
         sdc.AttributeName,
         sdc.IACUC,
         sdc.Project,
         sdc.CreatedBy,
         sdc.Created,
         sdc.ModifiedBy,
         sdc.Modified,
         sdc.ObjectId

PIVOT Values by AttributeName IN ('blood_volume', 'Reason')

order by id, date desc
