/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('SNPRC_EHR.panel.ColonyOverviewPanel', {
    extend: 'EHR.panel.ColonyOverviewPanel',
    alias: 'widget.snprc-ehr-colonyoverviewpanel',

    border: false,
    defaults: {
        border: false
    },

    initComponent: function () {
        this.filterArray = [
            LABKEY.Filter.create('calculated_status', 'Alive', LABKEY.Filter.Types.EQUAL)
            //LABKEY.Filter.create('gender/meaning', 'Unknown', LABKEY.Filter.Types.NEQ)
        ];
        this.childFilterArray = [
            LABKEY.Filter.create('Id/demographics/calculated_status', 'Alive', LABKEY.Filter.Types.EQUAL)
            //LABKEY.Filter.create('Id/demographics/gender/meaning', 'Unknown', LABKEY.Filter.Types.NEQ)
        ];

        this.items = [{
            xtype: 'labkey-bootstraptabpanel',
            description: 'This page is designed to give an overview of the colony.',
            items: this.getItems()
        }];

        // maintain context in callbacks and events //this.callParent(); replaced with...
        this.superclass.superclass.initComponent.apply(this);
    }
});