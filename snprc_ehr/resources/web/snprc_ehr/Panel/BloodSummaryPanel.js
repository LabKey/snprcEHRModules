/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @param subjects
 */
Ext4.define('SNPRC.panel.BloodSummaryPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.snprc-bloodsummarypanel',
    intervals: {},
    plotHeight: 400,

    initComponent: function(){
        Ext4.apply(this, {
            border: false,
            defaults: {
                border: false
            }
        });

        this.callParent();

        var target = this.add({
            xtype: 'ehr-bloodsummarypanel',
            subjects: this.subjects,
            getSubjectItems: this.summaryItems
        });


        if (!Ext4.isFunction(target.getWith)) {
            target.getWidth = function () {
                return 700;
            }
        }
    },

    summaryItems: function(subject, demographics) {
        var toAdd = [];
        toAdd.push({
            html: '',
            border: false,
            style: 'margin-bottom: 10px;'
        });

        toAdd.push({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom: 10px;',
            queryConfig: LDK.Utils.getReadOnlyQWPConfig({
                title: 'Recent Blood Draws: ' + subject,
                schemaName: 'study',
                queryName: 'bloodDrawsByDay',
                allowHeaderLock: false,
                //frame: 'none',
                filters: [
                    LABKEY.Filter.create('Id', subject, LABKEY.Filter.Types.EQUAL),
                    LABKEY.Filter.create('date', '-' + (demographics.getValue('species/blood_draw_interval') * 2) + 'd', LABKEY.Filter.Types.DATE_GREATER_THAN_OR_EQUAL)
                ],
                sort: '-date'
            })
        });

        toAdd.push({
            html: '',
            border: false,
            style: 'margin-bottom: 10px;'
        });

        return toAdd;
    }
});
