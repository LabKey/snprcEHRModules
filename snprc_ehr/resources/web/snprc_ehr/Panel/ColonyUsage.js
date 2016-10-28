/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */


Ext4.define('SNPRC.panel.ColonyUsagePanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.snprc-colonyusagepanel',

    initComponent: function(){
        Ext4.apply(this, {
            minHeight: 400,
            border: false,
            autoScroll: true,
            style: 'padding: 5px;'
        });

        this.callParent();

        this.add(this.getAssignedTable());

        //this.loadData();
    },

    getAssignedTable: function(){
        return {
            xtype: 'ldk-querypanel',
            style: 'margin: 5px;',
            queryConfig: {
                title: 'Assigned (funded)',
                containerPath: this.containerPath,
                schemaName: 'study',
                queryName: 'colonyUsage',
                filterArray: this.filterArray,
                failure: LDK.Utils.getErrorCallback()
            }
        }
    }
});