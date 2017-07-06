package org.labkey.snprc_ehr.views;

import org.apache.log4j.Logger;
import org.labkey.api.view.JspView;

public class AnimalsByLocationWebPart extends JspView
{
    private static final Logger _log = Logger.getLogger(AnimalsByLocationWebPart.class);

    public AnimalsByLocationWebPart()
    {
        super("/org/labkey/snprc_ehr/views/AnimalsByLocation.jsp", null);

        setTitle("Animals By Location");

    }
}
