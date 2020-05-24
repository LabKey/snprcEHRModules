/*
 * Copyright (c) 2017-2019 LabKey Corporation
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
package org.labkey.snprc_ehr.controllers;

import org.labkey.api.action.FormViewAction;
import org.labkey.api.action.SimpleRedirectAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.pipeline.PipeRoot;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.PipelineService;
import org.labkey.api.pipeline.PipelineStatusUrls;
import org.labkey.api.pipeline.PipelineValidationException;
import org.labkey.api.pipeline.browse.PipelinePathForm;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.snprc_ehr.pipeline.FeeScheduleExcelParser;
import org.labkey.snprc_ehr.pipeline.FeeScheduleImportForm;
import org.labkey.snprc_ehr.pipeline.FeeSchedulePipelineJob;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.ModelAndView;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * Created by thawkins on 10/27/2017.
 */
public class FeeScheduleController extends SpringActionController
{

    public static final String NAME = "FeeSchedule";
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(FeeScheduleController.class);


    public FeeScheduleController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermission(AdminPermission.class)
    public class ImportFeeScheduleAction extends SimpleRedirectAction<PipelinePathForm>
    {
        // handles the request from the Pipeline's "Process And Import Data" page and
        // redirects to the FeeScheduleImportAction
        public ActionURL getRedirectURL(PipelinePathForm form) throws Exception
        {
            Container c = getContainer();
            File file = form.getValidatedSingleFile(c);

            if (!file.exists())
            {
                throw new Exception("File not found");
            }

            ActionURL url = new ActionURL(FeeScheduleImportAction.class, c);
            url.addParameter("filePath", file.getAbsolutePath());
            //url.addParameter("tabPage", "");
            //form.getRequest().getSession().setAttribute("tabPage", "");
            return url;
        }
    }


    /**
     * Landing page for a Fee Schedule Import
     */
    @RequiresPermission(AdminPermission.class)
    public class FeeScheduleImportAction extends FormViewAction<FeeScheduleImportForm>
    {
        private String _navTrail = "Import Fee Schedule";
        private File _fsFile;
        private String _tabPage;
        private ActionURL _url;

        @Override
        public ModelAndView getView(FeeScheduleImportForm form, boolean reshow, BindException errors) throws Exception
        {
            String fileSize;
            String dateString;
            File file = null;
            SimpleDateFormat formatString = new SimpleDateFormat("MM/dd/yyyy hh:mm");

            List<String> tabPageNames;
            FeeScheduleExcelParser fsep;
            if (form.getFilePath() != null)
            {
                file = new File(form.getFilePath());
            }
            if (file != null && file.exists())
            {
                fileSize = file.length() >= 1024 ? Long.toString(file.length() / 1024) + " KB" : Long.toString(file.length()) + " bytes";
                try
                {
                    dateString = formatString.format(new Date(file.lastModified()));
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }
            else
            {
                throw new PipelineJobException("File not selected.");
            }
            try
            {
                fsep = new FeeScheduleExcelParser(file);
                tabPageNames = fsep.getTabPageNames();

            }
            catch (PipelineJobException ex)
            {
                throw new PipelineJobException(ex.getMessage());
            }
            form.setFilePath(file.getAbsolutePath());
            form.setName(file.getName());
            form.setDate(dateString);
            form.setSize(fileSize);
            form.setAvailableTabPages(tabPageNames);

            _navTrail += form.getNavtrail();
            return new JspView<>("/org/labkey/snprc_ehr/pipeline/FeeScheduleImport.jsp", form, errors);
        }

        @Override
        public void validateCommand(FeeScheduleImportForm form, Errors errors)
        {
            _fsFile = new File(form.getFilePath());
            // Be sure that the referenced file exists
            if (_fsFile == null || !_fsFile.exists())
            {
                errors.reject(ERROR_MSG, "Could not find file at path: " + form.getFilePath());
            }
        }
        @Override
        public boolean handlePost(FeeScheduleImportForm form, BindException errors)
        {
            //queues up the pipeline job
            try
            {
                PipeRoot pipelineRoot = PipelineService.get().findPipelineRoot(getContainer());
                PipelineService.get().queueJob(new FeeSchedulePipelineJob(getContainer(), getUser(), getViewContext().getActionURL(), pipelineRoot, _fsFile, form));

                _url = PageFlowUtil.urlProvider(PipelineStatusUrls.class).urlBegin(getContainer().getProject());
                _url.addParameter("StatusFiles.containerFilterName", ContainerFilter.Type.CurrentAndSubfolders.name());

                return true;
            }
            catch (PipelineValidationException e)
            {
                errors.reject(ERROR_MSG, e.getMessage());
                return false;
            }
        }

        @Override
        public URLHelper getSuccessURL(FeeScheduleImportForm form)
        {
            return _url;
        }

        @Override
        public void addNavTrail(NavTree root)
        {
            root.addChild(_navTrail);
        }
    }
}