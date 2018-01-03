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
import org.labkey.snprc_ehr.pipeline.FeeSchedulePipelineJob;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.ModelAndView;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

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
        public ActionURL getRedirectURL(PipelinePathForm form) throws Exception
        {
            Container c = getContainer();
            File file = form.getValidatedSingleFile(c);
            String fileSize;
            String dateString;
            SimpleDateFormat formatString = new SimpleDateFormat("MM/dd/yyyy hh:mm");

            if (file != null)
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
                throw new Exception("File not selected");
            }

            ActionURL url = new ActionURL(FeeScheduleImportAction.class, getContainer());
            url.addParameter("filePath", file.getAbsolutePath());
            url.addParameter("name", file.getName());
            url.addParameter("size", fileSize);
            url.addParameter("date", dateString);
            return url;
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return null;
        }
    }

    /**
     * Landing page for FeeScheduleImportAction
     */
    @RequiresPermission(AdminPermission.class)
    public class FeeScheduleImportAction extends FormViewAction<FeeScheduleImportForm>
    {
        private String _navTrail = "Import Fee Schedule";
        private File _fsFile;

        @Override
        public void validateCommand(FeeScheduleImportForm form, Errors errors)
        {
            PipeRoot currentPipelineRoot = PipelineService.get().findPipelineRoot(getContainer());
            if (!PipelineService.get().hasValidPipelineRoot(getContainer()) || null == currentPipelineRoot)
            {
                errors.reject(ERROR_MSG, "Pipeline root not found.");
            }
            else if (form.getFilePath() == null)
            {
                errors.reject(ERROR_MSG, "No filePath provided.");
            }
            else
            {
                _fsFile = new File(form.getFilePath());
                if (!_fsFile.isAbsolute())
                {
                    // Resolve the relative path to an absolute path under the current container's root
                    _fsFile = currentPipelineRoot.resolvePath(form.getFilePath());
                }

                // Be sure that the referenced file exists and is under the pipeline root
                if (_fsFile == null || !_fsFile.exists())
                {
                    errors.reject(ERROR_MSG, "Could not find file at path: " + form.getFilePath());
                }
                else if (!currentPipelineRoot.isUnderRoot(_fsFile))
                {
                    errors.reject(ERROR_MSG, "Cannot access file " + form.getFilePath());
                }
            }
        }

        @Override
        public ModelAndView getView(FeeScheduleImportForm form, boolean reshow, BindException errors) throws Exception
        {
            _navTrail += form.getNavtrail();
            return new JspView<>("/org/labkey/snprc_ehr/pipeline/FeeScheduleImport.jsp", form, errors);
        }

        @Override
        public boolean handlePost(FeeScheduleImportForm form, BindException errors) throws PipelineJobException
        {

            if (_fsFile.exists())
            {
                try
                {
                    PipeRoot pipelineRoot = PipelineService.get().findPipelineRoot(getContainer());
                    PipelineService.get().queueJob(new FeeSchedulePipelineJob(getContainer(), getUser(), getViewContext().getActionURL(), pipelineRoot, _fsFile, form));

                    return true;
                }

                catch (PipelineValidationException e)
                {
                    errors.reject(ERROR_MSG, e.getMessage());
                    return false;
                }

            }

            return false;
        }

        @Override
        public URLHelper getSuccessURL(FeeScheduleImportForm form)
        {
            Container c = getContainer();

            ActionURL url = PageFlowUtil.urlProvider(PipelineStatusUrls.class).urlBegin(c.getProject());
            url.addParameter("StatusFiles.containerFilterName", ContainerFilter.Type.CurrentAndSubfolders.name());
            return url;

        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild(_navTrail);
        }

    }

    public static class FeeScheduleImportForm
    {
        private String _filePath;
        private String _name;
        private String _size;
        private String _date;
        private String _navTrail;

        public String getSize()
        {
            return _size;
        }

        public void setSize(String size)
        {
            _size = size;
        }

        public String getDate()
        {
            return _date;
        }

        public void setDate(String date)
        {
            _date = date;
        }

        public String getNavtrail()
        {
            return " - " + _name;
        }

        public String getFilePath()
        {

            return _filePath;
        }

        public void setFilePath(String filePath)
        {
            _filePath = filePath;
        }

        public String getName()
        {
            return _name;
        }

        public void setName(String name)
        {
            this._name = name;
        }
    }
}
