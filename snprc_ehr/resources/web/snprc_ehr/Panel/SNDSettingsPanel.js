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
            }
            ]
        });

        this.callParent();
    },

    success: function () {
        LABKEY.Utils.alert("Success","Tables updated successfully.");
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