/*
 * Copyright (c) 2014-2018 LabKey Corporation
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

package org.labkey.snprc_ehr;

import org.labkey.api.action.FormViewAction;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.snprc_ehr.notification.SSRSConfigManager;
import org.labkey.snprc_ehr.security.ManageLookupTablesPermission;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.ModelAndView;

import java.net.MalformedURLException;
import java.net.URL;

public class SNPRC_EHRController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(SNPRC_EHRController.class);
    public static final String NAME = "snprc_ehr";

    public SNPRC_EHRController()
    {
        setActionResolver(_actionResolver);
    }

    public static class SSRSConfigForm
    {
        private String _user;
        private String _password;
        private String _baseURL;

        public String getUser()
        {
            return _user;
        }

        public void setUser(String user)
        {
            _user = user;
        }

        public String getPassword()
        {
            return _password;
        }

        public void setPassword(String password)
        {
            _password = password;
        }

        public String getBaseURL()
        {
            return _baseURL;
        }

        public void setBaseURL(String baseURL)
        {
            _baseURL = baseURL;
        }
    }

    @RequiresPermission(AdminPermission.class)
    public class SSRSConfigAction extends FormViewAction<SSRSConfigForm>
    {
        @Override
        public void validateCommand(SSRSConfigForm target, Errors errors)
        {
            try
            {
                new URL(target.getBaseURL());
            }
            catch (MalformedURLException e)
            {
                errors.reject("baseURL", "Bad base URL. " + (e.getMessage() == null ? "" : e.getMessage()));
            }
        }

        @Override
        public ModelAndView getView(SSRSConfigForm form, boolean reshow, BindException errors)
        {
            if (!reshow)
            {
                form.setUser(SSRSConfigManager.getInstance().getUser(getContainer()));
                form.setPassword(SSRSConfigManager.getInstance().getPassword(getContainer()));
                form.setBaseURL(SSRSConfigManager.getInstance().getBaseURL(getContainer()));
            }
            return new JspView<>("/org/labkey/snprc_ehr/ssrsConfig.jsp", form, errors);
        }

        @Override
        public boolean handlePost(SSRSConfigForm form, BindException errors) throws Exception
        {
            SSRSConfigManager.getInstance().setProperties(getContainer(), form.getUser(), form.getPassword(), form.getBaseURL());
            return true;
        }

        @Override
        public URLHelper getSuccessURL(SSRSConfigForm ssrsConfigForm)
        {
            return new ActionURL(SNPRC_EHRController.NAME, "ehrAdmin", getContainer());
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("SSRS Configuration");
        }
    }

    @RequiresPermission(ManageLookupTablesPermission.class)
    public class EditLookupTablesAction extends SimpleViewAction
    {

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            root.addChild("Lookup Table Admin", new ActionURL(true));
            return root;
        }


        @Override
        public ModelAndView getView(Object o, BindException errors)
        {
            return new JspView<>("/org/labkey/snprc_ehr/views/EditLookupTables.jsp");
        }

    }
}