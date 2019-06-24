package org.labkey.snprc_scheduler.services;

import org.json.JSONArray;
import org.json.JSONObject;
import org.labkey.api.action.ApiUsageException;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;
import org.labkey.api.snd.SNDService;
import org.labkey.api.snprc_scheduler.SNPRC_schedulerService;
import org.labkey.snprc_scheduler.SNPRC_schedulerManager;
import org.labkey.snprc_scheduler.SNPRC_schedulerSchema;
import org.labkey.snprc_scheduler.domains.StudyDayNotes;
import org.labkey.snprc_scheduler.domains.Timeline;
import org.labkey.snprc_scheduler.domains.TimelineAnimalJunction;
import org.labkey.snprc_scheduler.domains.TimelineItem;
import org.labkey.snprc_scheduler.domains.TimelineProjectItem;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by thawkins on 10/21/2018
 */
public class SNPRC_schedulerServiceImpl implements SNPRC_schedulerService
{
    public static final SNPRC_schedulerServiceImpl INSTANCE = new SNPRC_schedulerServiceImpl();

    private SNPRC_schedulerServiceImpl()
    {
    }

    public List<Map<String, Object>> getActiveProjects(Container c, User u, ArrayList<SimpleFilter> filters)
    {

        return SNDService.get().getActiveProjects(c, u, filters);

    }

    /**
     * returns a list of active timelines for a projectId/RevisionNum (via projectObjectId)
     */

    public List<JSONObject> getActiveTimelines(Container c, User u, String projectObjectId, BatchValidationException errors) throws ApiUsageException
    {
        List<JSONObject> timelinesJson = new ArrayList<>();
        try
        {
            UserSchema schema = SNPRC_schedulerManager.getSNPRC_schedulerUserSchema(c, u);
            TableInfo timelineTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE, schema.getDefaultContainerFilter(), false, false);
            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("ProjectObjectId"), projectObjectId, CompareType.EQUAL);

            List<Timeline> timelines = new TableSelector(timelineTable, filter, null).getArrayList(Timeline.class);

            for (Timeline timeline : timelines)
            {
                timeline.setTimelineItems(SNPRC_schedulerManager.get().getTimelineItems(timeline.getObjectId(), null));
                timeline.setTimelineAnimalItems(SNPRC_schedulerManager.get().getTimelineAnimalItems(c, u, timeline.getObjectId()));
                timeline.setTimelineProjectItems(SNPRC_schedulerManager.get().getTimelineProjectItems(timeline.getObjectId()));
                timeline.setStudyDayNotes(SNPRC_schedulerManager.get().getStudyDayNotes(timeline.getObjectId()));
                timeline.setCreatedByName(SNPRC_schedulerManager.getUserDisplayName(timeline.getCreatedBy()));
                timeline.setModifiedByName(SNPRC_schedulerManager.getUserDisplayName(timeline.getModifiedBy()));

                timelinesJson.add(timeline.toJSON(c, u));
            }
        }
        catch (Exception e)
        {
            throw new ApiUsageException(e);
        }

        return timelinesJson;
    }


    //TODO: need to add scheduleDate criteria
    public List<JSONObject> getScheduledTimelinesForSpecies(Container c, User u, String species, BatchValidationException errors) throws ApiUsageException
    {
        List<JSONObject> timelinesJson = new ArrayList<>();
        try
        {
            UserSchema schema = SNPRC_schedulerManager.getSNPRC_schedulerUserSchema(c, u);
            TableInfo timelineTable = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE, schema.getDefaultContainerFilter(), false, false);

            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("Species"), species, CompareType.EQUAL);

            List<Timeline> timelines = new TableSelector(timelineTable, filter, null).getArrayList(Timeline.class);

            for (Timeline timeline : timelines)
            {
                timeline.setTimelineItems(SNPRC_schedulerManager.get().getTimelineItems(timeline.getObjectId(), null));
                timeline.setTimelineAnimalItems(SNPRC_schedulerManager.get().getTimelineAnimalItems(c, u, timeline.getObjectId()));
                timeline.setTimelineProjectItems(SNPRC_schedulerManager.get().getTimelineProjectItems(timeline.getObjectId()));
                timeline.setCreatedByName(SNPRC_schedulerManager.getUserDisplayName(timeline.getCreatedBy()));
                timeline.setModifiedByName(SNPRC_schedulerManager.getUserDisplayName(timeline.getModifiedBy()));

                timelinesJson.add(timeline.toJSON(c, u));
            }
        }
        catch (Exception e)
        {
            throw new ApiUsageException(e);
        }

        return timelinesJson;
    }





    /**
     * Save Timeline and associated datasets (called by SNPRC_schedulerServiceImpl.SNPRC_schedulerController.updateTimelineAction())
     *
     * @param c    = Container object
     * @param u    = User object
     * @param json = JSONObject from submitted form
     * @return errors = exception object
     */
    // TODO: Create automated test cases
    public JSONObject saveTimelineData(Container c, User u, JSONObject json, BatchValidationException errors)
    {

        JSONObject responseJson = new JSONObject();

        Timeline timeline = new Timeline(c, u, json); // get timeline object from json
        List<TimelineItem> timelineItems = new ArrayList<>();
        List<TimelineProjectItem> timelineProjectItems = new ArrayList<>();
        List<TimelineAnimalJunction> timelineAnimalItems = new ArrayList<>();
        List<StudyDayNotes> studyDayNotes = new ArrayList<>();

        UserSchema schema = SNPRC_schedulerManager.getSNPRC_schedulerUserSchema(c, u);
        //UserSchema schema = QueryService.get().getUserSchema(u, c, "snprc_ehr");
        DbScope scope = schema.getDbSchema().getScope();

        // Is the timeline going to be deleted?
        if (timeline.getDeleted())
        {
            SNPRC_schedulerManager.get().deleteTimeline(c, u, timeline, errors);

            // TODO: need to add response json

        }
        else
        {
            try (DbScope.Transaction transaction = scope.ensureTransaction())
            {
                // Validate new timeline for saving (throws BatchValidationException)
                SNPRC_schedulerServiceValidator.validateNewTimeline(timeline, c, u, errors);

                SNPRC_schedulerManager.get().updateTimeline(c, u, timeline, errors);

                // update the Timelineitem table
                if (!errors.hasErrors())
                {
                    // Get timeline items from json
                    JSONArray timelineItemsJsonArray = json.has(Timeline.TIMELINE_TIMELINE_ITEMS) ? json.getJSONArray(Timeline.TIMELINE_TIMELINE_ITEMS) : null;
                    if (timelineItemsJsonArray != null)
                    {
                        for (int i = 0, size = timelineItemsJsonArray.length(); i < size; i++)
                        {
                            if (TimelineItem.isValidTimelineItem(timelineItemsJsonArray.getJSONObject(i)))
                            {
                                TimelineItem newItem = new TimelineItem(timelineItemsJsonArray.getJSONObject(i));
                                // add the timelineObjectId before using the object (it may have been created within this transaction)
                                newItem.setTimelineObjectId(timeline.getObjectId());
                                timelineItems.add(newItem);
                            }
                        }
                    }
                    SNPRC_schedulerServiceValidator.validateNewTimelineItems(timelineItems, timeline, c, u, errors);

                    SNPRC_schedulerManager.get().updateTimelineItems(c, u, timelineItems, errors); //new BatchValidationException());
                }

                // update TimelineProjectItem table
                if (!errors.hasErrors())
                {

                    // Get timeline project items from json
                    JSONArray timelineProjectItemsJsonArray = json.has(Timeline.TIMELINE_TIMELINE_PROJECT_ITEMS) ? json.getJSONArray(Timeline.TIMELINE_TIMELINE_PROJECT_ITEMS) : null;
                    if (timelineProjectItemsJsonArray != null)
                    {
                        for (int i = 0, size = timelineProjectItemsJsonArray.length(); i < size; i++)
                        {
                            TimelineProjectItem newItem = new TimelineProjectItem(timelineProjectItemsJsonArray.getJSONObject(i));
                            // add the timelineObjectId before using the object (it may have been created within this transaction)
                            newItem.setTimelineObjectId(timeline.getObjectId());
                            timelineProjectItems.add(newItem);

                        }
                    }
                    SNPRC_schedulerServiceValidator.validateNewTimelineProjectItems(timelineProjectItems, timeline, c, u, errors);

                    SNPRC_schedulerManager.get().updateTimelineProjectItems(c, u, timelineProjectItems, errors); //new BatchValidationException());
                }

                // update the TimelineAnimalJunction table
                if (!errors.hasErrors())
                {
                    // Get animal ids from json
                    JSONArray timelineAnimalItemsJsonArray = json.has(Timeline.TIMELINE_ANIMAL_ITEMS) ? json.getJSONArray(Timeline.TIMELINE_ANIMAL_ITEMS) : null;
                    if (timelineAnimalItemsJsonArray != null)
                    {
                        for (int i = 0, size = timelineAnimalItemsJsonArray.length(); i < size; i++)
                        {
                            TimelineAnimalJunction newItem = new TimelineAnimalJunction(timelineAnimalItemsJsonArray.getJSONObject(i));
                            // add the timelineObjectId before using the object (it may have been created within this transaction)
                            newItem.setTimelineObjectId(timeline.getObjectId());
                            timelineAnimalItems.add(newItem);
                        }
                    }
                    SNPRC_schedulerServiceValidator.validateNewTimelineAnimalItems(timelineAnimalItems, timeline, c, u, errors);

                    SNPRC_schedulerManager.get().updateTimelineAnimalItems(c, u, timelineAnimalItems, errors); //new BatchValidationException());
                }
                // update the StudyDayNotes table
                if (!errors.hasErrors())
                {
                    // Get study day notes from json
                    JSONArray studyDayNotesJsonArray = json.has(Timeline.TIMELINE_STUDY_DAY_NOTES) ? json.getJSONArray(Timeline.TIMELINE_STUDY_DAY_NOTES) : null;
                    if (studyDayNotesJsonArray != null)
                    {
                        for (int i = 0, size = studyDayNotesJsonArray.length(); i < size; i++)
                        {
                            StudyDayNotes newItem = new StudyDayNotes(studyDayNotesJsonArray.getJSONObject(i));
                            // add the timelineObjectId before using the object (it may have been created within this transaction)
                            newItem.setTimelineObjectId(timeline.getObjectId());
                            studyDayNotes.add(newItem);
                        }
                    }
                    //ToDo: StudyDayNote valdation

                    SNPRC_schedulerManager.get().updateStudyDayNotes(c, u, studyDayNotes, errors); //new BatchValidationException());
                }
                transaction.commit();

                //       JSON form has been parsed into these objects:
                //       Timeline timeline
                //       List<TimelineItem> timelineItems
                //       List<TimelineProjectItem> timelineProjectItems
                //       List<TimelineItem> timelineAnimalJunction

                if (!errors.hasErrors())
                {
                    timeline.setTimelineItems(timelineItems);
                    timeline.setTimelineProjectItems(timelineProjectItems);
                    timeline.setTimelineAnimalItems(timelineAnimalItems);
                    timeline.setStudyDayNotes(studyDayNotes);

                    responseJson = timeline.toJSON(c, u);

                }

            }
            catch (BatchValidationException b)
            {
                // Message has already been concatenated to errors variable
            }
            catch (RuntimeException e)
            {
                errors.addRowError(new ValidationException(e.getMessage()));
            }
        }
        return responseJson;
    }
}
