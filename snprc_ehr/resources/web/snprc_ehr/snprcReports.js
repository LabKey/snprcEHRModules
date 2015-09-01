/*
 * Copyright (c) 2012-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('EHR.reports');

//this contains SNPRC-specific reports that should be loaded on the animal history page
//this file is registered with EHRService, and should auto-load whenever EHR's
//dependencies are requested, provided this module is enabled

EHR.reports.underDevelopment = function(panel, tab){
    tab.add({
        xtype: 'panel',
        border: false,
        html: 'The site is currently under development and we expect this tab to be enabled soon.',
        bodyStyle: 'padding: 5px;',
        defaults: {
            border: false
        }
    });
};

EHR.reports.hematology = function(panel, tab){
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

    var miscConfig = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'hematologyMisc',
        title: "Misc Tests" + title,
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querypanel',
        style: 'margin-bottom:20px;',
        queryConfig: miscConfig
    });

    // No reference range data currently available for SNPRC
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
