/*
 * Copyright (c) 2017-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.snprc_ehr.pipeline;

import org.labkey.api.data.Container;
import org.labkey.api.pipeline.CancelledException;
import org.labkey.api.pipeline.PipeRoot;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.security.User;
import org.labkey.api.util.FileUtil;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.ViewBackgroundInfo;

import java.io.File;

/**
 * Created by thawkins 10/23/2017
 */

public class FeeSchedulePipelineJob extends PipelineJob
{

    private File _importFile;
    private Container _container;
    private FeeScheduleImportForm _form;
    private User _user;

    // For serialization
    protected FeeSchedulePipelineJob() {}

    public FeeSchedulePipelineJob(Container c, User user, ActionURL url, PipeRoot pipeRoot, File importFile, FeeScheduleImportForm form)
    {
        super(null, new ViewBackgroundInfo(c, user, url), pipeRoot);
        _importFile = importFile;
        setLogFile(new File(pipeRoot.getRootPath(), FileUtil.makeFileNameWithTimestamp("FeeSchedulePipeline", "log")));
        _form = form;
        _container = c;
        _user = user;
    }

    @Override
    public void run()
    {
        try
        {
            setStatus(TaskStatus.running);
            importFile();
            if (getActiveTaskStatus() == TaskStatus.error)
            {
                info("Processing fee schedule completed with errors");
            }
            else
            {
                info("Processing fee schedule complete");
            }
        }
        catch (CancelledException e)
        {
            setActiveTaskStatus(TaskStatus.cancelled);
            info("Processing Fee Schedule cancelled");
        }
        catch (Exception e)
        {
            error("Processing Fee Schedule failed", e);
            setStatus(TaskStatus.error);

            info("Processing Fee schedule failed");
        }
    }

    @Override
    public URLHelper getStatusHref()
    {
        return null;
    }

    @Override
    public String getDescription()
    {
        return "Import SNPRC Fee Schedule from Excel file";
    }

    private void importFile()
    {
        int rows;
        FeeScheduleExcelParser fsep = new FeeScheduleExcelParser(_container, _user, _importFile, _form);
        try
        {
            fsep.parseFile();
            rows = fsep.loadTable();
            setStatus(TaskStatus.complete);
            info("Imported " + rows + " rows from " + _importFile);
        }
        catch (PipelineJobException e)
        {
            setStatus(TaskStatus.error);
            getLogger().warn(e.getMessage());
        }
        getLogger().info("Ran import job: FeeSchedulePipelineJob.importFile()");
    }
}
