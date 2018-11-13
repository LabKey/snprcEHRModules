package org.labkey.snprc_ehr.pipeline;

import org.labkey.api.pipeline.PipeRoot;
import org.labkey.api.pipeline.PipelineDirectory;
import org.labkey.api.pipeline.PipelineProvider;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.util.FileUtil;
import org.labkey.api.view.ViewContext;
import org.labkey.api.module.Module;
import org.labkey.snprc_ehr.controllers.FeeScheduleController;

import java.io.File;
import java.io.FileFilter;

/**
 * User: thawkins
 * Date: October 23, 2017
 */

    public class FeeSchedulePipelineProvider extends PipelineProvider
    {
        public static final String NAME = "FeeSchedulePipeline";

        FileFilter _fileMaskFilter = null;

        public FeeSchedulePipelineProvider(Module owningModule)
        {
            super(NAME, owningModule);
            _fileMaskFilter = new FileMaskFilter();
        }

        @Override
        public void updateFileProperties(ViewContext context, PipeRoot pr, PipelineDirectory directory, boolean includeAll)
        {
            // Only admins can import folders
            if (!context.getContainer().hasPermission(context.getUser(), AdminPermission.class))
                return;

            String actionId = createActionId(FeeScheduleController.ImportFeeScheduleAction.class, null);
            addAction(actionId, FeeScheduleController.ImportFeeScheduleAction.class, "Fee Schedule", directory, directory.listFiles(_fileMaskFilter), false, false, includeAll);
        }

        public static File logForInputFile(File f, PipeRoot pipeRoot)
        {
            return new File(pipeRoot.getRootPath(), FileUtil.makeFileNameWithTimestamp(f.getName(), "log"));
        }

        private static class FileMaskFilter implements FileFilter
        {
            public boolean accept(File file)
            {
                return file.getName().toLowerCase().endsWith(".xls") || file.getName().toLowerCase().endsWith(".xlsx");
            }
        }
    }
