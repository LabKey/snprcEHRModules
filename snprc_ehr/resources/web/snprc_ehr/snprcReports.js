/*
 * Copyright (c) 2012-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('EHR.reports');

//this contains SNPRC-specific reports that should be loaded on the animal history page
//this file is registered with EHRService, and should auto-load whenever EHR's
//dependencies are requested, provided this module is enabled
EHR.reports.urinalysis = function(panel, tab) {
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'urinalysisPivot',
        title: "By Panel" + title,
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });
};
EHR.reports.miscTests = function(panel, tab) {
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'miscPivot',
        title: "Under construction - additional work is still needed on this report", //By Panel" + title,
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });
};
EHR.reports.hematology = function(panel, tab)
{
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'hematologyPivot',
        title: "By Panel" + title,
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    // All tests are currently configured to be part of the panel, so this will always be blank
    //var miscConfig = panel.getQWPConfig({
    //    schemaName: 'study',
    //    queryName: 'hematologyMisc',
    //    title: "Misc Tests" + title,
    //    titleField: 'Id',
    //    sort: '-date',
    //    filters: filterArray.nonRemovable,
    //    removeableFilters: filterArray.removable
    //});
    //
    //tab.add({
    //    xtype: 'ldk-querypanel',
    //    style: 'margin-bottom:20px;',
    //    queryConfig: miscConfig
    //});

    // Reference range data not yet split into separate min/max values so disabling for now
    //var resultsConfig = panel.getQWPConfig({
    //    schemaName: 'study',
    //    queryName: 'hematologyRefRange',
    //    //viewName: 'Plus Ref Range',
    //    title: "Reference Ranges:",
    //    titleField: 'Id',
    //    filters: filterArray.nonRemovable,
    //    removeableFilters: filterArray.removable
    //});
    //
    //tab.add({
    //    xtype: 'ldk-querypanel',
    //    style: 'margin-bottom:20px;',
    //    queryConfig: resultsConfig
    //});
};

EHR.reports.bloodChemistry = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'chemPivot',
        title: "By Panel" + title,
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    // All tests are currently configured to be part of the panel, so this will always be blank. Uncomment when/if
    // ehr_lookups.lab_tests data changes

    //config = panel.getQWPConfig({
    //    schemaName: 'study',
    //    queryName: 'chemMisc',
    //    title: "Misc Tests:",
    //    titleField: 'Id',
    //    sort: '-date',
    //    filters: filterArray.nonRemovable,
    //    removeableFilters: filterArray.removable
    //});
    //
    //tab.add({
    //    xtype: 'ldk-querypanel',
    //    style: 'margin-bottom:20px;',
    //    queryConfig: config
    //});


    // Reference range data not yet split into separate min/max values so disabling for now

    //config = panel.getQWPConfig({
    //    schemaName: 'study',
    //    queryName: 'chemistryRefRange',
    //    //viewName: 'Plus Ref Range',
    //    title: "Reference Ranges:",
    //    titleField: 'Id',
    //    sort: '-date',
    //    filters: filterArray.nonRemovable,
    //    removeableFilters: filterArray.removable
    //});
    //
    //tab.add({
    //    xtype: 'ldk-querypanel',
    //    style: 'margin-bottom:20px;',
    //    queryConfig: config
    //});
};

EHR.reports.surveillance = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'surveillancePivot',
        title: "By Panel" + title,
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    // All tests are currently configured to be part of the panel, so this will always be blank. Uncomment when/if
    // ehr_lookups.lab_tests data changes

    //config = panel.getQWPConfig({
    //    schemaName: 'study',
    //    queryName: 'surveillanceMisc',
    //    title: "Misc Tests:",
    //    titleField: 'Id',
    //    sort: '-date',
    //    filters: filterArray.nonRemovable,
    //    removeableFilters: filterArray.removable
    //});
    //
    //tab.add({
    //    xtype: 'ldk-querypanel',
    //    style: 'margin-bottom:20px;',
    //    queryConfig: config
    //});


    // Reference range data not yet split into separate min/max values so disabling for now

    //config = panel.getQWPConfig({
    //    schemaName: 'study',
    //    queryName: 'surveillanceRefRange',
    //    //viewName: 'Plus Ref Range',
    //    title: "Reference Ranges:",
    //    titleField: 'Id',
    //    sort: '-date',
    //    filters: filterArray.nonRemovable,
    //    removeableFilters: filterArray.removable
    //});
    //
    //tab.add({
    //    xtype: 'ldk-querypanel',
    //    style: 'margin-bottom:20px;',
    //    queryConfig: config
    //});
};

EHR.reports.proceduresBeforeDisposition = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'encounters',
        viewName: 'ProceduresBeforeDisposition',
        title: "Procedure Before Disposition " + title,
        filters: filterArray.nonRemovable,
        removeableFilters: [LABKEY.Filter.create('survivorship/survivorshipInDays', 3, LABKEY.Filter.Types.LESS_THAN_OR_EQUAL)]
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });
};

EHR.reports.currentBlood = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        html: 'This report summarizes the blood available for the animals below.  ' +
       '<br><br>If there have been recent blood draws for the animal, a graph will show the available blood over time.  On the graph, dots indicate dates when either blood was drawn or a previous blood draw fell off.  The horizontal lines indicate the maximum allowable blood that can be drawn on that date.',
        border: false,
        style: 'padding-bottom: 20px;'
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom: 10px;',
        queryConfig: panel.getQWPConfig({
            title: 'Summary',
            schemaName: 'study',
            queryName: 'Demographics',
            viewName: 'Blood Draws',
            filterArray: filterArray.removable.concat(filterArray.nonRemovable)
        })
    });

    var subjects = tab.filters.subjects || [];

    if (subjects.length){
        tab.add({
            xtype: 'snprc-bloodsummarypanel',
            subjects: subjects
        });
    }
    else
    {
        panel.resolveSubjectsFromHousing(tab, function(subjects, tab){
            tab.add({
                xtype: 'snprc-bloodsummarypanel',
                subjects: subjects
            });
        }, this);
    }
};
