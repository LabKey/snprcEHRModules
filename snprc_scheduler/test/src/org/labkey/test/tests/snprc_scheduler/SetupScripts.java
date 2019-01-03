package org.labkey.test.tests.snprc_scheduler;


public class SetupScripts
{
    private static final int PKG_ID1 = 5000;
    private static final int PKG_ID2 = 5002;
    private static final int PKG_ID3 = 5004;
    private static final int SUPER_PKG_ID_START = 10000;
    private static final int SUPER_PKG_ID1 = 10001;
    private static final int SUPER_PKG_ID2 = 10002;
    private static final int SUPER_PKG_ID3 = 10003;
    private static final int PROJECT_ID = 500;
    private static final int REVISION_NUM = 1;
    private static final int PROJECT_REF_ID = 100;
    private static final String PROJECT_START_DATE = "2018-01-01";
    private static final String PROJECT_END_DATE = "2018-01-02";
    private static final String PROJECT_DESC = "Project Test";

    public static final String ADD_PKG1 = "LABKEY.Ajax.request({   \n" +
            "    method: 'POST',                                                    \n" +
            "    url: LABKEY.ActionURL.buildURL('snd', 'savePackage.api'),          \n" +
            "    success: function(){ callback('Success!'); },                      \n" +
            "    failure: function(e){ callback(e.responseText); },                 \n" +
            "    jsonData: {                                                        \n" +
            "        'id' : '" + PKG_ID1 + "',                                  \n" +
            "		 'testIdNumberStart': '" + SUPER_PKG_ID_START + "',        \n" +
            "        'description': 'Test PKG 1 decription',                       \n" +
            "        'active': true,                                                \n" +
            "        'repeatable': true,                                            \n" +
            "        'narrative': 'This is a narrative for {SNDName1} ({SNDUser1}), age {SNDAge1}',\n" +
            "        'categories': [],                                              \n" +
            "        'subPackages': [],                                             \n" +
            "        'extraFields': {'UsdaCode':'B'},                               \n" +
            "        'attributes': []                                              \n" +
            "    }                                                                  \n" +
            "})";
    public static final String ADD_PKG2 = "LABKEY.Ajax.request({   \n" +
            "    method: 'POST',                                                    \n" +
            "    url: LABKEY.ActionURL.buildURL('snd', 'savePackage.api'),          \n" +
            "    success: function(){ callback('Success!'); },                      \n" +
            "    failure: function(e){ callback(e.responseText); },                 \n" +
            "    jsonData: {                                                        \n" +
            "        'id' : '" + (PKG_ID2) + "',                                  \n" +
            "		 'testIdNumberStart': '" + SUPER_PKG_ID_START + "',        \n" +
            "        'description': 'Test PKG 2 decription',                       \n" +
            "        'active': true,                                                \n" +
            "        'repeatable': true,                                            \n" +
            "        'narrative': 'This is a narrative for {SNDName2} ({SNDUser2}), age {SNDAge2}',\n" +
            "        'categories': [],                                              \n" +
            "        'subPackages': [],                                             \n" +
            "        'extraFields': {'UsdaCode':'B'},                               \n" +
            "        'attributes': []                                              \n" +
            "    }                                                                  \n" +
            "})";

    public static final String ADD_PKG3 = "LABKEY.Ajax.request({   \n" +
            "    method: 'POST',                                                    \n" +
            "    url: LABKEY.ActionURL.buildURL('snd', 'savePackage.api'),          \n" +
            "    success: function(){ callback('Success!'); },                      \n" +
            "    failure: function(e){ callback(e.responseText); },                 \n" +
            "    jsonData: {                                                        \n" +
            "        'id' : '" + (PKG_ID3) + "',                                  \n" +
            "		 'testIdNumberStart': '" + SUPER_PKG_ID_START + "',        \n" +
            "        'description': 'Test PKG 3 decription',                       \n" +
            "        'active': true,                                                \n" +
            "        'repeatable': true,                                            \n" +
            "        'narrative': 'This is a narrative for {SNDName3} ({SNDUser3}), age {SNDAge3}',\n" +
            "        'categories': [],                                              \n" +
            "        'subPackages': [],                                             \n" +
            "        'extraFields': {'UsdaCode':'B'},                               \n" +
            "        'attributes': []                                              \n" +
            "    }                                                                  \n" +
            "})";


        public static String ADD_PROJECT1 = "LABKEY.Ajax.request({      \n" +
                "  method: 'POST',\n" +
                "  url: LABKEY.ActionURL.buildURL('snd', 'saveProject.api'),\n" +
                "  success: function(){ callback('Success!'); },\n" +
                "  failure: function(e){ callback('Failed'); },\n" +
                "  jsonData: {                                             \n" +
                "       \"projectId\": '" + PROJECT_ID + "',                \n" +
                "       \"revisionNum\": '" + REVISION_NUM + "',             \n" +
                "       \"endDate\": '" + PROJECT_END_DATE + "',  \n" +
                "       \"startDate\": '" + PROJECT_START_DATE + "',  \n" +
                "       \"isRevision\": 'false',  \n" +
                "       \"isEdit\": 'false',  \n" +
                "       \"copyRevisedPkgs\": 'false',  \n" +
                "       \"description\": '" + PROJECT_DESC + "',  \n" +
                "       \"active\": 'true',  \n" +
                "       \"referenceId\": '" + PROJECT_REF_ID + "',  \n" +
                "       \"projectItems\": \n" +
                "       [{" +
                "            \"superPkgId\":" + SUPER_PKG_ID1 + ", \"active\":true}, \n" +
                "           {\"superPkgId\":" + SUPER_PKG_ID2 + ", \"active\":true}, \n" +
                "           {\"superPkgId\":" + SUPER_PKG_ID3 + ", \"active\":true}]\n" +
                "       }\n" +
                "});\n";

    public SetupScripts()
    {
    }
}
