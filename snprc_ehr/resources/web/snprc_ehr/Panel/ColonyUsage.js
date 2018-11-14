/*
 * Copyright (c) 2016-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */


Ext4.define('SNPRC.panel.ColonyUsagePanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.snprc-colonyusagepanel',

    initComponent: function(){

        this.items = [
            this.getQueryCmpConfig('Active IACUC Assignments', 'study', 'colonyUsage'),
            this.getQueryCmpConfig('Assigned (funded)', 'study', 'baboonAssignedColonyUsage'),
            this.getQueryCmpConfig('Breeding/Colony Use', 'study', 'baboonBreedingColonyUsage'),
            this.getQueryCmpConfig('Unassigned', 'study', 'baboonUnassignedColonyUsage'),
            this.getQueryCmpConfig('Age Classes (in years)', 'ehr_lookups', 'AgeClassPivot')
        ];

        this.callParent();
    },

    getQueryCmpConfig: function(title, schemaName, queryName) {
        return {
            xtype: 'ldk-querycmp',
            margin: '0 0 20px 0',
            queryConfig: {
                title: title,
                frame: 'dialog',
                containerPath: this.containerPath,
                schemaName: schemaName,
                queryName: queryName,
                filterArray: this.filterArray,
                failure: LDK.Utils.getErrorCallback(),
                scope: this,
                success: function() {
                    this.doLayout();
                }
            }
        }
    }
});