package org.labkey.snprc_ehr.steps;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.SqlExecutor;
import org.labkey.api.data.TableInfo;
import org.labkey.api.di.TaskRefTaskImpl;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.RecordedActionSet;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;

/**
 * Calls TAC_src.usp_FanOutBiocontainmentObservations (in the animal database, via the
 * tacSrc external schema) after step1 of ExportBiocontainmentObservations.xml has
 * already merged edited rows into TAC_src.BiocontainmentObservations and committed.
 *
 * This exists as a separate post-merge step, rather than a trigger on
 * TAC_src.BiocontainmentObservations, because LabKey's bulkLoad="true"
 * targetOption="merge" write uses an OUTPUT clause (without INTO) to
 * report rows copied - and SQL Server disallows OUTPUT without INTO on any
 * statement whose target table has an enabled trigger for that action.
 * A trigger there failed every run with "Optimistic concurrency exception:
 * Table deleted" (confirmed by toggling the trigger disabled/enabled -
 * disabled succeeds every time, enabled fails every time, including on a
 * 0-row merge). Running the fan-out as a stored procedure after step1 has
 * already committed avoids that conflict entirely - see the header comment
 * in resources/source_queries/create_CAMP_BiocontainmentObservations.sql for the
 * fuller story and the policy decisions baked into the procedure itself.
 */
public class BiocontainmentObservationsFanOutTask extends TaskRefTaskImpl
{
    private static final String TAC_SRC_SCHEMA_NAME = "tacSrc";
    private static final String LANDING_TABLE_NAME = "BiocontainmentObservations";

    private void runFanOut(PipelineJob job) throws PipelineJobException
    {
        Container c = job.getContainer();

        UserSchema schema = QueryService.get().getUserSchema(job.getUser(), c, TAC_SRC_SCHEMA_NAME);
        if (schema == null)
            throw new PipelineJobException("Could not find schema " + TAC_SRC_SCHEMA_NAME + " in " + c.getPath());

        TableInfo ti = schema.getTable(LANDING_TABLE_NAME);
        if (ti == null)
            throw new PipelineJobException("Could not find table " + LANDING_TABLE_NAME + " in schema " + TAC_SRC_SCHEMA_NAME + " in " + c.getPath());

        DbSchema dbSchema = ti.getSchema();
        DbScope scope = dbSchema.getScope();

        job.getLogger().info("Calling TAC_src.usp_FanOutBiocontainmentObservations");
        new SqlExecutor(scope).execute("EXEC TAC_src.usp_FanOutBiocontainmentObservations");
        job.getLogger().info("Fan-out to CAMP complete");
    }

    @Override
    public RecordedActionSet run(@NotNull PipelineJob job)
    {
        try
        {
            runFanOut(job);
        }
        catch (Exception e)
        {
            // Unlike BiocontainmentObservationsAuditLogTask (where a logging failure
            // is acceptable to swallow), a failure here means TAC edits did
            // not actually reach CAMP - this must fail the pipeline step
            // rather than report success, so a real problem (e.g. a CHECK
            // constraint rejecting an out-of-range value, a missing
            // dependency like editCommentBuffer) is visible to whoever
            // monitors these ETL jobs instead of being silently swallowed.
            job.getLogger().error(e.getMessage(), e);
            throw new RuntimeException("BiocontainmentObservationsFanOutTask failed: " + e.getMessage(), e);
        }
        return new RecordedActionSet(makeRecordedAction());
    }
}
