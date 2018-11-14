/*
 * Copyright (c) 2017-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('EHR.panel.SNDSettingsPanel', {
    extend: 'Ext.panel.Panel',

    initComponent: function () {
        Ext4.apply(this, {
            border: false,
            width: 400,
            defaults: {
                border: false
            },
            items: [{
                html: 'This page provides settings and actions for the SND module.',
                style: 'padding-bottom: 10px'
            }, {
                html: "<a class='labkey-text-link' href='" + LABKEY.ActionURL.buildURL('snd', 'admin') + "'>SND Module Admin Settings</a>",
                style: 'padding-bottom: 10px'
            }, {
                xtype: 'button',
                text: 'Generate SNPRC custom columns',
                scope: this,
                handler: this.createDomainHandler
            }
            ]
        });

        this.callParent();
    },

    success: function () {
        LABKEY.Utils.alert("Success","Action executed successfully.");
    },

    failure: function (e) {
        LABKEY.Utils.alert("Error", e.exception);
    },

    createDomainHandler: function () {
        LABKEY.Domain.create({
            success: this.success,
            failure: this.failure,
            domainGroup: "snd",
            domainKind: "SND",
            module: "snprc_ehr",
            importData: false
            });
    }
});