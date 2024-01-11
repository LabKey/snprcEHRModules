package org.labkey.api.snprc_scheduler;


import org.jetbrains.annotations.Nullable;
import org.json.JSONObject;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.security.User;
import org.labkey.api.services.ServiceRegistry;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by thawikins on 10/21/2018
 */

public interface SNPRC_schedulerService
{
    @Nullable
    static SNPRC_schedulerService get()
    {
        return ServiceRegistry.get(SNPRC_schedulerService.class);
    }

    List<JSONObject> getActiveTimelines(Container c, User u, String ProjectObjectId, BatchValidationException errors);
    List<JSONObject> getScheduledTimelinesForSpecies(Container c, User u, String species, Date date, BatchValidationException errors);
    List<Map<String, Object>> getActiveProjects(Container c, User u, ArrayList<SimpleFilter> filters, Boolean activeProjectItemsOnly);
    JSONObject saveTimelineData(Container c, User u, JSONObject json, BatchValidationException errors);
}

