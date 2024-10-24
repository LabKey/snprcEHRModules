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
            @Override
            public boolean accept(File file)
            {
                return file.getName().toLowerCase().endsWith(".xls") || file.getName().toLowerCase().endsWith(".xlsx");
            }
        }
    }
