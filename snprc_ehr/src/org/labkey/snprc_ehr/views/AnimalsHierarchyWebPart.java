package org.labkey.snprc_ehr.views;

import org.apache.log4j.Logger;
import org.labkey.api.view.JspView;

public class AnimalsHierarchyWebPart extends JspView
{
    private static final Logger _log = Logger.getLogger(AnimalsHierarchyWebPart.class);

    public AnimalsHierarchyWebPart()
    {
        super("/org/labkey/snprc_ehr/views/AnimalsHierarchy.jsp", null);

        setTitle("Animals By Locations, Groups, and Projects");

    }
}
