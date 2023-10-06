package org.labkey.snprc_ehr.steps;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Container;
import org.labkey.api.di.TaskRefTaskImpl;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.RecordedActionSet;
import org.labkey.api.query.ValidationError;

import java.util.List;

public class PackageLoadTask extends TaskRefTaskImpl
{
    @Override
    public RecordedActionSet run(@NotNull PipelineJob pipelineJob) throws PipelineJobException
    {
        return null;
    }

    @Override
    public List<ValidationError> preFlightCheck(Container c)
    {
        return super.preFlightCheck(c);
    }
}
