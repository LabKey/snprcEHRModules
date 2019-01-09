
package org.labkey.snprc_scheduler.services;

import org.labkey.api.data.Container;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.security.User;
import org.labkey.snprc_scheduler.domains.Timeline;
import org.labkey.snprc_scheduler.domains.TimelineAnimalJunction;
import org.labkey.snprc_scheduler.domains.TimelineItem;
import org.labkey.snprc_scheduler.domains.TimelineProjectItem;

import java.util.List;

/* Created by Charles Peterson on December 13, 2018 */

public class SNPRC_schedulerServiceValidator
{

    public static void validateNewTimeline(Timeline timeline, Container c, User u, BatchValidationException errors) throws BatchValidationException
    {
        // Check Dates
        if (timeline.getStartDate() == null || timeline.getEndDate() == null ||
                timeline.getStartDate().after(timeline.getEndDate()))
        {
            //throw errors.addRowError(new ValidationException("Timeline End Date is before Start Date"));
        }

        // Check that ProjectId is specified
        if (timeline.getProjectId() == null || timeline.getProjectRevisionNum() == null)
        {
            //throw errors.addRowError(new ValidationException("Timeline Project or Revision not specified"));

        }
        else
        {
            // TODO: Check that ProjectId is valid and editable

            // (If new timeline, it will not yet have timelineId)
            if (timeline.getTimelineId() != null)
            {

                //TODO: Check that timeling having TimelineId is editable

                //TODO: Check that this revision is valid and editable

            }
        }

    }

    public static void validateNewTimelineItems(List<TimelineItem> newItems, Timeline timeline, Container c, User u, BatchValidationException errors) throws BatchValidationException
    {
        //TODO: Validate TimelineItems
    }

    public static void validateNewTimelineProjectItems(List<TimelineProjectItem> newItems, Timeline timeline, Container c, User u, BatchValidationException errors) throws BatchValidationException
    {
        //TODO: Validate TimelineProjectItems
    }

    public static void validateNewTimelineAnimalItems(List<TimelineAnimalJunction> newItems, Timeline timeline, Container c, User u, BatchValidationException errors) throws BatchValidationException
    {
        //TODO: Validate TimelineAnimalJunction items
    }

}
