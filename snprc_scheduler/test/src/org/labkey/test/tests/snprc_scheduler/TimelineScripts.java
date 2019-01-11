package org.labkey.test.tests.snprc_scheduler;

import java.util.ArrayList;
import java.util.Map;

public class TimelineScripts
{

    public static final Integer TIMELINE_ID = 101;
    public static final Integer REVISION_NUM = 0;

    public String addTimelineScript(String testProjectObjectId, ArrayList<Map<String, Integer>> projectItems)
    {
        Integer projectItemId1 = 0;
        Integer projectItemId2 = 0;
        Integer projectItemId3 = 0;


        if (testProjectObjectId != null)
        {
            projectItemId1 = projectItems.get(0).get("ProjectItemId");
            projectItemId2 = projectItems.get(1).get("ProjectItemId");
            projectItemId3 = projectItems.get(2).get("ProjectItemId");
        }

        String timelineScript = "LABKEY.Ajax.request({\n" +
                "    method: 'POST',\n" +
                "    url: LABKEY.ActionURL.buildURL('snprc_scheduler', 'updateTimeline.api'),\n" +
                "    success: function(){ callback('Success!'); },\n" +
                "    failure: function(e){ callback(e.responseText); },\n" +
                "    jsonData: {\n" +
                "        'TimelineId'  : "+ TIMELINE_ID + ",\n" +
                "        'RevisionNum'  : "+ REVISION_NUM + ",\n" +
                "        'IsDeleted'  : false ,\n" +
                "        'Description' : 'Timeline #1 revision 1',\n" +
                "        'ProjectObjectId' : '" + testProjectObjectId + "',\n" +
                "        'SchedulerNotes' : 'Of all the things ive lost in life, i miss my mind the most',\n" +
                "        'EndDate' : '2018/12/30 00:00:00',\n" +
                "        'Created' : '2018/09/20 00:00:00',\n" +
                "        'StartDate' : '2018/02/01 00:00:00',\n" +
                "        'LeadTechs' : 'Henry Ford, Nicoli Tesla',\n" +
                "        'Notes' : 'Dont take any wooden nickels.',\n" +
                "        'TimelineItems' : [\n" +
                "          { 'IsDirty' : true ,\n" +
                "           'StudyDay' : 0,\n" +
                "           'ScheduleDate' : null,\n" +
                "           'ProjectItemId' : " + projectItemId1 + "},\n" +
                "          { 'IsDirty' : true ,\n" +
                "           'StudyDay' : 1,\n" +
                "           'ScheduleDate' : null,\n" +
                "           'ProjectItemId' : " + projectItemId2 + "},\n" +
                "          { 'IsDirty' : true ,\n" +
                "           'StudyDay' : 2,\n" +
                "           'ScheduleDate' : null,\n" +
                "           'ProjectItemId' : " + projectItemId1 + "},\n" +
                "          { 'IsDirty' : true ,\n" +
                "           'StudyDay' : 2,\n" +
                "           'ScheduleDate' : null,\n" +
                "           'ProjectItemId' : " + projectItemId3 + "}\n" +
                "        ],\n" +
                "        'TimelineProjectItems' : [\n" +
                "           { 'SortOrder' : 0,\n" +
                "           'ProjectItemId'  : " + projectItemId1 + ",\n" +
                "           'TimelineFootNotes' : 'Bla bla bla note 1' },\n " +
                "           {'SortOrder' : 0,\n" +
                "           'ProjectItemId'  : " + projectItemId2 + ",\n" +
                "           'TimelineFootNotes' : 'Bla bla bla note 2' },\n " +
                "           {'SortOrder' : 0,\n" +
                "           'ProjectItemId'  : " + projectItemId3 + ",\n" +
                "           'TimelineFootNotes' : 'Bla bla bla note 3' }\n " +
                "       ],\n" +
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

        return timelineScript;
    }

    public String deleteTimelineScript(String testProjectObjectId, String timelineObjectId)
    {
        String timelineScript = "LABKEY.Ajax.request({\n" +
                "    method: 'POST',\n" +
                "    url: LABKEY.ActionURL.buildURL('snprc_scheduler', 'updateTimeline.api'),\n" +
                "    success: function(){ callback('Success!'); },\n" +
                "    failure: function(e){ callback(e.responseText); },\n" +
                "    jsonData: {\n" +
                "        'TimelineId'  : "+ TIMELINE_ID + ",\n" +
                "        'RevisionNum'  : "+ REVISION_NUM + ",\n" +
                "        'IsDeleted'  : true ,\n" +
                "        'Description' : 'Timeline #1 revision 1',\n" +
                "        'ProjectObjectId' : '" + testProjectObjectId + "',\n" +
                "        'SchedulerNotes' : 'Of all the things ive lost in life, i miss my mind the most',\n" +
                "        'EndDate' : '2018/12/30 00:00:00',\n" +
                "        'Created' : '2018/09/20 00:00:00',\n" +
                "        'StartDate' : '2018/02/01 00:00:00',\n" +
                "        'LeadTechs' : 'Henry Ford, Nicoli Tesla',\n" +
                "        'Notes' : 'Dont take any wooden nickels.',\n" +
                "        'ObjectId' : '" + timelineObjectId + "',\n" +
                "        'TimelineItems' : [\n" +
                "        ],\n" +
                "        'TimelineProjectItems' : [\n" +
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
                "       if (typeof json !== undefined && rows[0].ObjectId === '" + timelineObjectId + "')\n" +
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
