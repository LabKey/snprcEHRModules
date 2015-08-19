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