/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('EHR.panel.SNDSettingsPanel', {
    extend: 'Ext.panel.Panel',

    initComponent: function () {
        Ext4.apply(this, {
            border: false,
            defaults: {
                border: false
            },
            items: [{
                html: 'This page provides settings and actions for the SND module.',
                style: 'padding-bottom: 20px'
            }, {
                xtype: 'button',
                text: 'Generate custom columns',
                scope: this,
                handler: this.createDomainHandler
            }, {
                xtype: 'button',
                style: 'margin-left:10px',
                text: 'Refresh event narrative cache',
                scope: this,
                handler: this.refreshNarrativeCacheHandler
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
    },

    refreshNarrativeCacheHandler: function () {
        LABKEY.Ajax.request({
            success: this.success,
            failure: this.failure,
            url: LABKEY.ActionURL.buildURL('snd', 'refreshNarrativeCache.api'),
            params: {},
            scope: this,
        });
    }
});