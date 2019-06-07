package org.labkey.test.tests.snprc_scheduler;

import java.util.ArrayList;
import java.util.Map;

import static org.labkey.test.util.TestLogger.log;

public class TimelineScripts
{

    public static final Integer TIMELINE_ID = 101;
    public static final Integer REVISION_NUM = 0;

    public String saveTimelineScript(String testTimelineObjectId, String testProjectObjectId, ArrayList<Map<String, Object>> projectItems, ArrayList<Map<String, Object>> timelineItems)
    {
        Integer projectItemId1 = 0;
        Integer projectItemId2 = 0;
        Integer projectItemId3 = 0;

        if (testProjectObjectId != null)
        {
            projectItemId1 = (Integer) projectItems.get(0).get("ProjectItemId");
            projectItemId2 = (Integer) projectItems.get(1).get("ProjectItemId");
            projectItemId3 = (Integer) projectItems.get(2).get("ProjectItemId");
        }

        String timelineScript = "LABKEY.Ajax.request({\n" +
                "    method: 'POST',\n" +
                "    url: LABKEY.ActionURL.buildURL('snprc_scheduler', 'updateTimeline.api'),\n" +
                "    success: function(data){\n" +
                "       var response = JSON.parse(data.response);\n" +
                "       if (response.success) {\n" +
                "             callback('Success!');\n" +
                "       }\n" +
                "       else {\n" +
                "             callback(response.responseText);\n" +
                "       }\n" +
                "    },\n" +
                "    failure: function(e){ callback(e.responseText); },\n" +
                "    jsonData: {\n";

        // if timelineObject id is not null then an update was requested
        // changed studyDay two to use a null projectItemId
        if (testTimelineObjectId != null)
        {
            timelineScript = timelineScript +
                    "        'ObjectId' : '" + testTimelineObjectId + "',\n" +
                    "        'TimelineId'  : " + TIMELINE_ID + ",\n" +
                    "        'RevisionNum'  : " + REVISION_NUM + ",\n" +
                    "        'IsDirty' : true,\n ";
        }
        else
        {
            timelineScript = timelineScript +
                    "        'ObjectId' : null ,\n" +
                    "        'TimelineId'  : null ,\n" +
                    "        'RevisionNum'  : null ,\n" +
                    "        'IsDirty' : null, \n ";
        }
        timelineScript = timelineScript +
                "        'IsInUse'  : false ,\n" +
                "        'IsDeleted'  : false ,\n" +
                "        'Description' : 'Timeline #1 revision 1',\n" +
                "        'ProjectObjectId' : '" + testProjectObjectId + "',\n" +
                "        'SchedulerNotes' : 'Of all the things ive lost in life, i miss my mind the most',\n" +
                "        'EndDate' : '2018-12-30',\n" +
                "        'Created' : '2018-09-20',\n" +
                "        'StartDate' : '2018-02-01',\n" +
                "        'LeadTechs' : 'Henry Ford, Nicoli Tesla',\n" +
                "        'RC' : 'Mouse, Mikey',\n" +
                "        'Notes' : 'Dont take any wooden nickels.',\n" +
        /*
                Add TimelineItems
         */
                // item 1
                "        'TimelineItems' : [\n" +
                "          { 'IsDirty' : true ,\n" +
                "           'StudyDay' : 0,\n" +
                "           'ProjectItemId' : " + projectItemId1 + ",\n" +
                "           'ScheduleDate' : null,\n";
        if (testTimelineObjectId != null)
        {   //update
            timelineScript = timelineScript +
                    "           'TimelineItemId' : " + timelineItems.get(0).get("TimelineItemId") + ",\n" +
                    "           'ObjectId' : '" + timelineItems.get(0).get("ObjectId") + "'";
        }
        else
        {   //insert
            timelineScript = timelineScript +
                    // Test missing TimelineItemId (should be treated as null value by API)
                    //"           'TimelineItemId' : null,\n" +
                    "           'ObjectId' : null";
        }
        timelineScript = timelineScript + " },\n" +

                // item 2
                "          { 'IsDirty' : true ,\n" +
                "           'StudyDay' : 1,\n" +
                "           'ProjectItemId' : " + projectItemId2 + ",\n" +
                "           'ScheduleDate' : null,\n";
        if (testTimelineObjectId != null)
        {   //update
            timelineScript = timelineScript +
                    "           'TimelineItemId' : " + timelineItems.get(1).get("TimelineItemId") + ",\n" +
                    "           'ObjectId' : '" + timelineItems.get(1).get("ObjectId") + "'";
        }
        else
        {   //insert
            timelineScript = timelineScript +
                    "           'TimelineItemId' : null,\n" +
                    "           'ObjectId' : null";
        }
        timelineScript = timelineScript + " },\n" +

                // item 3
                "          { 'IsDirty' : true ,\n" +
                "           'StudyDay' : 2,\n" +
                "           'ScheduleDate' : null,\n";
        // insert projectItemId that is null or update it to projectItemId2
        if (testTimelineObjectId != null)
        {   //insert
            timelineScript = timelineScript +
                    "           'TimelineItemId' : " + timelineItems.get(2).get("TimelineItemId") + ",\n" +
                    "           'ObjectId' : '" + timelineItems.get(2).get("ObjectId") + "',\n" +
                    "           'ProjectItemId' : null";
        }
        else
        {   //update
            timelineScript = timelineScript +
                    "           'ObjectId' : null,\n" +
                    "           'ProjectItemId' : " + projectItemId2;
        }
        timelineScript = timelineScript + " },\n" +

                // item 4
                "          { 'IsDirty' : true ,\n" +
                "           'StudyDay' : 2,\n" +
                "           'ProjectItemId' : " + projectItemId3 + ",\n" +
                "           'ScheduleDate' : null,\n";
        if (testTimelineObjectId != null)
        {   //insert
            timelineScript = timelineScript +
                    "           'TimelineItemId' : " + timelineItems.get(3).get("TimelineItemId") + ",\n" +
                    "           'ObjectId' : '" + timelineItems.get(3).get("ObjectId") + "'";
        }
        else
        {   //update
            timelineScript = timelineScript +
                    "           'ObjectId' : null";
        }
        timelineScript = timelineScript +
                " }\n        ],\n" +


         /*
            Add TimelineProjectItems
          */
                "        'TimelineProjectItems' : [\n" +
                "           { 'SortOrder' : 0,\n";
        // updating the timeline add the projectItem objectId
        if (testTimelineObjectId != null)
        {
            timelineScript = timelineScript + "'ObjectId' : '" + projectItems.get(0).get("ObjectId") + "',\n";
        }
        timelineScript = timelineScript +
                "           'ProjectItemId'  : " + projectItemId1 + ",\n" +
                "           'TimelineFootNotes' : 'Bla bla bla note 1' },\n " +
                "           {'SortOrder' : 0,\n";
        // updating the timeline add the projectItem objectId
        if (testTimelineObjectId != null)
        {
            timelineScript = timelineScript + "'ObjectId' : '" + projectItems.get(1).get("ObjectId") + "',\n";
        }
        timelineScript = timelineScript +
                "           'ProjectItemId'  : " + projectItemId2 + ",\n" +
                "           'TimelineFootNotes' : 'Bla bla bla note 2' },\n " +
                "           {'SortOrder' : 0,\n";
        // updating the timeline add the projectItem objectId
        if (testTimelineObjectId != null)
        {
            timelineScript = timelineScript + "'ObjectId' : '" + projectItems.get(2).get("ObjectId") + "',\n";
        }
        timelineScript = timelineScript +
                "           'ProjectItemId'  : " + projectItemId3 + ",\n" +
                "           'TimelineFootNotes' : 'Bla bla bla note 3' }\n " +
                "       ],\n" +

        /*
                Add StudyDayNotes
         */
                // Note 1
                "        'StudyDayNotes' : [\n" +
                "          { 'IsDirty' : true ,\n" +
                "           'StudyDay' : 0,\n" +
                "           'StudyDayNote' : 'Bla bla bla day 0' ,\n";
        if (testTimelineObjectId != null)
        {   //update
            timelineScript = timelineScript +
                    "           'TimeLineObjectId' : '" + timelineItems.get(0).get("ObjectId") + "'";
        }
        else
        {   //insert
            timelineScript = timelineScript +
                    "           'TimelineObjectId' : null";
        }
        timelineScript = timelineScript +
                "       },\n" +

        // Note 2
                "          { 'IsDirty' : true ,\n" +
                "           'StudyDay' : 2,\n" +
                "           'StudyDayNote' : 'Bla bla bla day 2' ,\n";
        if (testTimelineObjectId != null)
        {   //update
            timelineScript = timelineScript +
                    "           'TimeLineObjectId' : '" + timelineItems.get(0).get("ObjectId") + "'";
        }
        else
        {   //insert
            timelineScript = timelineScript +
                    "           'TimelineObjectId' : null";
        }
        timelineScript = timelineScript +
                "       }],\n" +


        /*
                Add TimelineAnimalItems
        */
                "       'TimelineAnimalItems' : [\n" +
                "          { 'AnimalId' : '28385',\n" +
                "          'Gender' : 'F',\n" +
                "          'AssignmentStatus' : 'A',\n" +
                "          'EndDate' : null,\n" +
                "          'Weight' : 18.26,\n" +
                "          'Age' : '12.1 years'},\n" +
                "          { 'AnimalId' : '28368',\n" +
                "          'Gender' : 'F',\n" +
                "          'AssignmentStatus' : 'A',\n" +
                "          'EndDate' : null,\n" +
                "          'Weight' : 18.48,\n" +
                "          'Age' : '12.2 years'},\n" +
                "          { 'AnimalId' : '28386',\n" +
                "          'Gender' : 'M',\n" +
                "          'AssignmentStatus' : 'A',\n" +
                "          'EndDate' : null,\n" +
                "          'Weight' : 27.33,\n" +
                "          'Age' : '12.5 years'},\n" +
                "          { 'AnimalId' : '28387',\n" +
                "          'Gender' : 'M',\n" +
                "          'AssignmentStatus' : 'A',\n" +
                "          'EndDate' : null,\n" +
                "          'Weight' : 28.43,\n" +
                "          'Age' : '12.6 years'}\n" +
                "       ]}\n" +
                " })\n";
        log(timelineScript);

        return timelineScript;
    }


    public String deleteTimelineScript(String testProjectObjectId, String timelineObjectId)
    {
        String timelineScript = "LABKEY.Ajax.request({\n" +
                "    method: 'POST',\n" +
                "    url: LABKEY.ActionURL.buildURL('snprc_scheduler', 'updateTimeline.api'),\n" +
                "    success: function(data){\n" +
                "       var response = JSON.parse(data.response);\n" +
                "       if (response.success) {\n" +
                "             callback('Success!');\n" +
                "       }\n" +
                "       else {\n" +
                "             callback('Failure!');\n" +
                "       }\n" +
                "    },\n" +
                "    failure: function(e){ callback(e.responseText); },\n" +
                "    jsonData: {\n" +
                "        'TimelineId'  : " + TIMELINE_ID + ",\n" +
                "        'RevisionNum'  : " + REVISION_NUM + ",\n" +
                "        'IsDeleted'  : true ,\n" +
                "        'Description' : 'Timeline #1 revision 1',\n" +
                "        'ProjectObjectId' : '" + testProjectObjectId + "',\n" +
                "        'SchedulerNotes' : 'Of all the things ive lost in life, i miss my mind the most',\n" +
                "        'EndDate' : '2018-12-30',\n" +
                "        'Created' : '2018-09-20',\n" +
                "        'StartDate' : '2018-02-01',\n" +
                "        'LeadTechs' : 'Henry Ford, Nicoli Tesla',\n" +
                "        'Notes' : 'Dont take any wooden nickels.',\n" +
                "        'ObjectId' : '" + timelineObjectId + "',\n" +
                "        'TimelineItems' : [\n" +
                "        ],\n" +
                "        'TimelineProjectItems' : [\n" +
                "       ],\n" +
                "        'StudyDayNotes' : [\n" +
                "       ],\n" +
                "       'TimelineAnimalItems' : [\n" +
                "       ]}\n" +
                " })\n";

        return timelineScript;
    }

    public String getTimelineScript(String projectObjectId, String timelineObjectId)
    {
        String timelineScript = "LABKEY.Ajax.request({\n" +
                "    method: 'POST',\n" +
                "    url: LABKEY.ActionURL.buildURL('snprc_scheduler', 'getActiveTimelines.api'),\n" +
                "    params: {\n" +
                "        'projectObjectId' : '" + projectObjectId + "'\n" +
                "   },\n" +
                "   failure: function(e){ callback(e.responseText); },\n" +
                "   success: function(data) {\n" +
                "       var rows = JSON.parse(data.response).rows;\n" +
                "       if (typeof rows !== undefined && rows[0].ObjectId === '" + timelineObjectId + "')\n" +
                "       {\n" +
                "           callback('Success!');\n" +
                "       }\n" +
                "       else\n" +
                "       {\n" +
                "           callback('Failure');\n" +
                "       }\n" +
                "  }\n" +
                "});\n";
        return timelineScript;
    }

}
