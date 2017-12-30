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
import org.labkey.snprc_ehr.controllers.FeeScheduleController;

import java.io.File;
import java.sql.SQLException;

/**
 * Created by thawkins 10/23/2017
 */

public class FeeSchedulePipelineJob extends PipelineJob
{

    private File _importFile;
    private Container _container;
    private FeeScheduleController.FeeScheduleImportForm _form;
    private User _user;

    public FeeSchedulePipelineJob(Container c, User user, ActionURL url, PipeRoot pipeRoot, File importFile, FeeScheduleController.FeeScheduleImportForm form)
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

    private void importFile() throws PipelineJobException
    {
        int rows;
        FeeScheduleExcelParser fsep = new FeeScheduleExcelParser(_container, _user, _importFile);
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
