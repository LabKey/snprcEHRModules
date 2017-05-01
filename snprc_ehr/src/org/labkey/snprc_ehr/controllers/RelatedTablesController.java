package org.labkey.snprc_ehr.controllers;

import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.ehr.dataentry.DataEntryForm;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.WebPartView;
import org.labkey.snprc_ehr.security.ManageRelatedTablesPermission;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;

/**
 * Created by lkacimi on 4/12/2017.
 */
public class RelatedTablesController extends SpringActionController
{
    public static final String NAME = "RelatedTables";
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(RelatedTablesController.class);

    public RelatedTablesController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermission(ManageRelatedTablesPermission.class)
    public class GetValidInstitutionsViewAction extends SimpleViewAction<Object>
    {

        @Override
        public ModelAndView getView(Object form, BindException errors) throws Exception
        {

            JspView<DataEntryForm> view = new JspView("/org/labkey/snprc_ehr/views/ValidInstitutions.jsp", this);
            view.setTitle("Valid Institutions");
            view.setHidePageTitle(true);
            view.setFrame(WebPartView.FrameType.PORTAL);


            return view;
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("Valid Institutions");
        }
    }

    @RequiresPermission(ManageRelatedTablesPermission.class)
    public class GetValidVetsAction extends SimpleViewAction<Object>
    {

        @Override
        public ModelAndView getView(Object form, BindException errors) throws Exception
        {

            JspView<DataEntryForm> view = new JspView("/org/labkey/snprc_ehr/views/ValidVets.jsp", this);
            view.setTitle("Valid Vets");
            view.setHidePageTitle(true);
            view.setFrame(WebPartView.FrameType.PORTAL);


            return view;
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("Valid Vets");
        }
    }
    @RequiresPermission(ManageRelatedTablesPermission.class)
    public class GetValidBirthDeathCodesViewAction extends SimpleViewAction<Object>
    {

        @Override
        public ModelAndView getView(Object form, BindException errors) throws Exception
        {

            JspView<DataEntryForm> view = new JspView("/org/labkey/snprc_ehr/views/ValidBirthAndDeathCodes.jsp", this);
            view.setTitle("Valid Birth / Death Codes");
            view.setHidePageTitle(true);
            view.setFrame(WebPartView.FrameType.PORTAL);


            return view;
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("Valid Birth / Death Codes");
        }
    }


}
