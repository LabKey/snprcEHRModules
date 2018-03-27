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

        this.add(this.getBaboonBreederTable());

        this.add(this.getBaboonUnassignedTable());

        //this.add(this.getBaboonAgeClassTable());
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
    },
    getBaboonBreederTable: function(){
        return {
            xtype: 'ldk-querypanel',
            style: 'margin: 5px;',
            queryConfig: {
                title: 'Breeding/Colony Use',
                containerPath: this.containerPath,
                schemaName: 'study',
                queryName: 'baboonBreedingColonyUsage',
                filterArray: this.filterArray,
                failure: LDK.Utils.getErrorCallback()
            }
        }
    },
    getBaboonUnassignedTable: function(){
        return {
            xtype: 'ldk-querypanel',
            style: 'margin: 5px;',
            queryConfig: {
                title: 'Unassigned',
                containerPath: this.containerPath,
                schemaName: 'study',
                queryName: 'baboonUnassignedColonyUsage',
                filterArray: this.filterArray,
                failure: LDK.Utils.getErrorCallback()
            }
        }
    },
    getBaboonAgeClassTable: function(){
        return {
            xtype: 'ldk-querypanel',
            style: 'margin: 5px;',
            queryConfig: {
                title: 'Age Classes (in years)',
                containerPath: this.containerPath,
                schemaName: 'study',
                queryName: 'AgeClassPivot',
                filterArray: this.filterArray,
                failure: LDK.Utils.getErrorCallback()
            }
        }
    }

});