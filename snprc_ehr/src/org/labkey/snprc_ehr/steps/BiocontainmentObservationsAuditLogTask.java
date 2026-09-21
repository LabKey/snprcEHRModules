package org.labkey.snprc_ehr.steps;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.audit.AuditLogService;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.di.TaskRefTaskImpl;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.RecordedActionSet;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.study.Dataset;
import org.labkey.api.study.Study;
import org.labkey.api.study.StudyService;
import org.labkey.snprc_ehr.audit.BiocontainmentObservationsAuditProvider;
import org.labkey.snprc_ehr.services.SNPRC_EHRUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Logs a BiocontainmentObservationsAuditEvent for each row the BiocontainmentObservations ETL merged
 * since the last run. This exists because the ETL destination uses
 * bulkLoad="true" (see resources/etls/BiocontainmentObservations.xml), which bypasses
 * QueryUpdateService entirely - so neither dataset triggers nor the standard
 * DatasetAuditEvent audit trail ever fire for these writes. Wired in as a
 * second TaskRefTransformStep after the merge step.
 *
 * NOTE: this only covers inserts/updates picked up by the merge. Deletes are
 * not covered in here
 */
public class BiocontainmentObservationsAuditLogTask extends TaskRefTaskImpl
{
    private static final String DATASET_NAME = "BiocontainmentObservations";

    private static final int LOOKBACK_MINUTES = 15;

    private void logAuditEvents(PipelineJob job) throws PipelineJobException
    {
        Container c = job.getContainer();

        Study study = StudyService.get().getStudy(c);
        if (study == null)
        {
            job.getLogger().error("No study found in " + c.getPath());
            return;
        }

        Dataset ds = study.getDatasetByName(DATASET_NAME);
        if (ds == null)
        {
            job.getLogger().error("Could not find dataset " + DATASET_NAME + " in " + c.getPath());
            return;
        }

        UserSchema schema = QueryService.get().getUserSchema(job.getUser(), c, "study");
        if (schema == null)
        {
            throw new PipelineJobException("Could not find study schema in " + c.getPath());
        }

        TableInfo ti = schema.getTable(DATASET_NAME, schema.getDefaultContainerFilter());
        if (ti == null)
        {
            throw new PipelineJobException("Could not find table " + DATASET_NAME + " in " + c.getPath());
        }

        String since = SNPRC_EHRUtils.get().getQueryDateTime(-LOOKBACK_MINUTES);
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("modified"), since, CompareType.GTE);

        TableSelector ts = new TableSelector(ti, filter, null);
        Map<String, Object>[] rows = ts.getMapArray();

        if (rows == null || rows.length == 0)
        {
            job.getLogger().info("No new/modified rows found in " + DATASET_NAME + " to audit");
            return;
        }

        List<BiocontainmentObservationsAuditProvider.AuditEvent> events = new ArrayList<>();
        for (Map<String, Object> row : rows)
        {
            BiocontainmentObservationsAuditProvider.AuditEvent event = new BiocontainmentObservationsAuditProvider.AuditEvent(c, "ETL merge", ds.getDatasetId());
            Object lsid = row.get("lsid");
            if (lsid != null)
                event.setLsid(lsid.toString());
            events.add(event);
        }

        job.getLogger().info("Logging " + events.size() + " " + DATASET_NAME + " audit event(s)");
        AuditLogService.get().addEvents(job.getUser(), events);
    }

    @Override
    public RecordedActionSet run(@NotNull PipelineJob job)
    {
        try
        {
            logAuditEvents(job);
        }
        catch (Exception e)
        {
            job.getLogger().error(e.getMessage(), e);
        }
        return new RecordedActionSet(makeRecordedAction());
    }
}
