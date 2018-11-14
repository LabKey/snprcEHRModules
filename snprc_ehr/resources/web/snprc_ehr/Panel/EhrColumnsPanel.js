/*
 * Copyright (c) 2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

Ext4.define('EHR.panel.EhrColumnsPanel', {
    extend: 'Ext.panel.Panel',

    initComponent: function () {
        Ext4.apply(this, {
            border: false,
            width: 400,
            defaults: {
                border: false
            },
            items: [{
                html: 'This page is used to add extensible columns to the EHR tables (configured in domain-templates/ehr.template.xml).',
                style: 'padding-bottom: 10px'
            }, {
                xtype: 'button',
                text: 'Generate EHR extensible columns',
                scope: this,
                handler: this.createColumns
            }
            ]
        });

        this.callParent();
    },

    success: function () {
        LABKEY.Utils.alert("Success","successfully created columns.");
    },

    failure: function (e) {
        LABKEY.Utils.alert("Error", e.exception);
    },

    createColumns: function () {
        LABKEY.Domain.create({
            success: this.success,
            failure: this.failure,
            domainGroup: "ehr",
            domainKind: "EHR",
            module: "snprc_ehr",
            importData: false
        });
    }
});