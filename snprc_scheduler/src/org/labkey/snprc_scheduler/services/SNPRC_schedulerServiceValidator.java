
package org.labkey.snprc_scheduler.services;

import org.apache.commons.lang.StringUtils;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.snprc_scheduler.SNPRC_schedulerSchema;
import org.labkey.snprc_scheduler.domains.StudyDayNotes;
import org.labkey.snprc_scheduler.domains.Timeline;
import org.labkey.snprc_scheduler.domains.TimelineAnimalJunction;
import org.labkey.snprc_scheduler.domains.TimelineItem;
import org.labkey.snprc_scheduler.domains.TimelineProjectItem;
import org.labkey.api.query.ValidationException;
import org.labkey.snprc_scheduler.security.QCStateEnum;

import java.util.List;
import java.util.Map;

/* Created by Charles Peterson on December 13, 2018 */

public class SNPRC_schedulerServiceValidator
{

    public static void validateNewTimeline(Timeline timeline, Container c, User u, BatchValidationException errors) throws BatchValidationException
    {
        // Validate Dates Specified

        if (timeline.getEndDate() == null)  //start date defaults to current date in constructor
        {
            errors.addRowError(new ValidationException("Timeline End Date not specified")); //tested
            throw errors;
        }
        if (timeline.getEndDate().before(timeline.getStartDate()))
        {
            errors.addRowError(new ValidationException("Timeline End Date is before Start Date")); //tested
            throw errors;
        }

        // Validate Project Object, ProjectId, and ProjectRevNum

        Map<String, Object> row;
        Integer ProjId;
        Integer RevNum;
        if (timeline.getTimelineId() == null && StringUtils.isBlank(timeline.getObjectId())) // these tests only for new timelines
        {                                                                       // existing timelines tested for consistency later
            if (StringUtils.isBlank(timeline.getProjectObjectId()))
            {
                errors.addRowError(new ValidationException("Timeline Project ObjectId not specified")); //tested
                throw errors;
            }
            try
            {
                UserSchema schema = QueryService.get().getUserSchema(u, c, "snd");
                TableInfo ti = schema.getTable("Projects");
                SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("ObjectId"), timeline.getProjectObjectId(), CompareType.EQUAL);
                TableSelector ts = new TableSelector(ti, filter, null);
                row = ts.getMap();
            }
            catch (Exception e)
            {
                errors.addRowError(new ValidationException("Error finding project in Projects table: ")); //tested
                errors.addRowError(new ValidationException(e.getMessage()));
                throw errors;
            }
            if (row == null)
            {
                errors.addRowError(new ValidationException("Timeline Project not found in Projects table")); //tested
                throw errors;
            }
            try
            {
                ProjId = (Integer) row.get("ProjectId");
                RevNum = (Integer) row.get("RevisionNum");
            }
            catch (Exception e)
            {
                errors.addRowError(new ValidationException(e.getMessage()));
                errors.addRowError(new ValidationException("Unable to access ProjectId or RevisionNum in Projects table"));
                throw errors; // this error unlikely, indicates corrupted Projects table
            }
            if (timeline.getProjectId() != null && !timeline.getProjectId().equals(ProjId))
            {
                errors.addRowError(new ValidationException("Timeline ProjectId does not match Projects table")); //tested
                throw errors;
            }
            if (timeline.getProjectRevisionNum() != null && !timeline.getProjectRevisionNum().equals(RevNum))
            {
                errors.addRowError(new ValidationException("Timeline Project RevisionNum does not match Projects table")); //tested
                throw errors;
            }
        }


        // Validate Timeline Object

        Map<String, Object> timelineRow;

        if (timeline.getTimelineId() == null && StringUtils.isBlank(timeline.getObjectId()))  //tested
        {
            // All New Timeline, check json draft state (and other such checks here)
            //
            if (timeline.getQcState() != null && !timeline.getQcState().equals(QCStateEnum.IN_PROGRESS.getValue()))
            {
                errors.addRowError(new ValidationException("Timeline must be created in editable Draft state")); //tested
                throw errors;
            }
        }
        // check to see if we have a timeline objectId without a timeline id
        else if (timeline.getTimelineId() == null && StringUtils.isNotBlank(timeline.getObjectId()))  //tested
        {
            errors.addRowError(new ValidationException("TimelineId was not provided for update"));
            throw errors;
        }
        else
        {
            try
            {
                UserSchema schema = QueryService.get().getUserSchema(u, c, "snprc_scheduler");
                TableInfo ti = schema.getTable(SNPRC_schedulerSchema.TABLE_NAME_TIMELINE);
                SimpleFilter filter;
                if (StringUtils.isNotBlank(timeline.getObjectId()))
                // ObjectId present so we are Updating within the current revision
                // We can find the current revision Timeline using ObjectId
                {
                    filter = new SimpleFilter(FieldKey.fromParts("ObjectId"), timeline.getObjectId(), CompareType.EQUAL); //tested
                }
                else
                {
                    filter = new SimpleFilter(FieldKey.fromParts("TimelineId"), timeline.getTimelineId(), CompareType.EQUAL); //tested
                    filter.addCondition(FieldKey.fromParts("RevisionNum"), "0");
                }
                TableSelector ts = new TableSelector(ti, filter, null);
                timelineRow = ts.getMap();
            }
            catch (Exception e)
            {
                errors.addRowError(new ValidationException("Error finding timeline in Timeline table: ")); //tested
                errors.addRowError(new ValidationException(e.getMessage()));
                throw errors;
            }
            if (timelineRow == null)
            {
                if (StringUtils.isBlank(timeline.getObjectId()))
                {
                    errors.addRowError(new ValidationException("Timeline Revision 0 not found in Timeline table")); //tested!
                    throw errors;
                }
                else
                {
                    errors.addRowError(new ValidationException("Timeline not found in Timeline table")); //tested!
                    throw errors;
                }
            }
            else // We found the timeline in the database
            {
                // Make sure that things that shouldn't change haven't been changed
                //   Business Rules say that ProjectId and RevisionNum should not change

                if (timeline.getProjectId() != null && !timeline.getProjectId().equals(timelineRow.get("ProjectId")))
                {
                    errors.addRowError(new ValidationException("Invalid change to ProjectId")); //tested
                    throw errors;
                }
                if (timeline.getProjectRevisionNum() != null && !timeline.getProjectRevisionNum().equals(timelineRow.get("ProjectRevisionNum")))
                {
                    errors.addRowError(new ValidationException("Invalid change to ProjectRevisionNum")); //tested!
                    throw errors;
                }
                if (StringUtils.isBlank(timeline.getProjectObjectId()) || !timeline.getProjectObjectId().equals(timelineRow.get("ProjectObjectId")))
                {
                    errors.addRowError(new ValidationException("Invalid change to ProjectObjectId")); //tested
                    throw errors;
                }
                if (StringUtils.isNotBlank(timeline.getObjectId()))
                {
                    if (timeline.getTimelineId() != null && !timeline.getTimelineId().equals(timelineRow.get("TimelineId")))
                    {
                        errors.addRowError(new ValidationException("Invalid change to TimelineId")); //tested
                        throw errors;
                    }
                    if (timeline.getRevisionNum() != null && !timeline.getRevisionNum().equals(timelineRow.get("RevisionNum")))
                    {
                        errors.addRowError(new ValidationException("Invalid change to Timeline RevisionNum")); //tested!
                        throw errors;
                    }
                }

                // Ensure the Timeline is editable, according to the database (the pre-existing state!)
                //   From Business Rules and Most Important
                if (timelineRow.get("QcState") == null || !timelineRow.get("QcState").equals(QCStateEnum.IN_PROGRESS.getValue()))
                {
                    errors.addRowError(new ValidationException("Timeline is not in editable Draft state"));  //tested!
                    throw errors;
                }
            } //end of checks related to timeline in database
        } // end of checks to Timeline object itself
    } // end of ValidateNewTimeline

    // Earlier code from ValidateNewTimeline above saved for future reference:
    // DBSchema code in the following section no longer used, as SQLFragment is no longer
    // needed when just getting Revision 0 rather than "min" revision
    // We now just use the UserSchema with a SimpleFilter
    // DbSchema db = SNPRC_schedulerSchema.getInstance().getSchema();
    // SQLFragment sql = new SQLFragment("SELECT t1.projectObjectId FROM ");
    // // sql.append(ti, "t1"); Earlier UserSchema version
    // sql.append("snprc_scheduler.Timeline as t1 ");
    // sql.append("where t1.TimelineId = ? ");
    // sql.append("and t1.RevisionNum = 0 ");
    // sql.add(timeline.getTimelineId());
    // //Original design imagined rev 0 to be deletable, so we had to look for the minimum rev instead
    // sql.append ("and revisionNum = 1");
    // sql.append ("(select min(t2.RevisionNum)");
    // sql.append ("from Timeline as t2");
    // sql.append ("where t1.TimelineId = t2.TimelineId)"); */
    // String tst = sql.toString();
    // SqlSelector selector = new SqlSelector(db, sql);
    // pobj = selector.getObject(String.class);


        public static void validateNewTimelineItems (List < TimelineItem > newItems, Timeline timeline, Container
        c, User u, BatchValidationException errors) throws BatchValidationException
        {
            //TODO: Validate TimelineItems
        }

        public static void validateNewTimelineProjectItems (List < TimelineProjectItem > newItems, Timeline
        timeline, Container c, User u, BatchValidationException errors) throws BatchValidationException
        {
            //TODO: Validate TimelineProjectItems
        }

        public static void validateNewTimelineAnimalItems (List < TimelineAnimalJunction > newItems, Timeline
        timeline, Container c, User u, BatchValidationException errors) throws BatchValidationException
        {
            //TODO: Validate TimelineAnimalJunction items
        }

        public static void validateNewStudyDayNotes (List <StudyDayNotes> newItems, StudyDayNotes
                studyDayNotes, Container c, User u, BatchValidationException errors) throws BatchValidationException
        {
            //TODO: Validate StudyDayNotes
        }

    } // End of SNPRC_schedulerServiceValidator Class
