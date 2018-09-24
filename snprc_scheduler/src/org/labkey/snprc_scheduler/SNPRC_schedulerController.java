/*
 * Copyright (c) 2018 LabKey Corporation
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

package org.labkey.snprc_scheduler;

import org.labkey.api.action.ApiAction;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.snprc_scheduler.domains.Timeline;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;

import java.util.HashMap;
import java.util.Map;


public class SNPRC_schedulerController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(SNPRC_schedulerController.class);
    public static final String NAME = "snprc_scheduler";

    public SNPRC_schedulerController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermission(ReadPermission.class)
    public class BeginAction extends SimpleViewAction
    {

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root;

        }

        @Override
        public ModelAndView getView(Object bla, BindException errors)
        {

            return new JspView<>("/org/labkey/snprc_scheduler/view/hello.jsp");
        }


    }

    //http://deepthought:8080/labkey/snprc_scheduler/snprc/getBla.view?
    @RequiresPermission(ReadPermission.class)
    public class GetBlaAction extends ApiAction<Timeline>
    {
        @Override
        public ApiResponse execute(Timeline o, BindException errors)
        {

            Map<String, Object> props = new HashMap<String, Object>();

            props.put("rows", "This is a test");

            return new ApiSimpleResponse(props);
        }
    }



//    @RequiresPermission(ReadPermission.class)
//    public class BeginAction extends SimpleViewAction
//    {
//        public ModelAndView getView(Object o, BindException errors)
//        {
//            return new JspView("/org/labkey/snprc_scheduler/view/hello.jsp");
//        }
//
//        public NavTree appendNavTrail(NavTree root)
//        {
//            return root;
//        }
//    }


}