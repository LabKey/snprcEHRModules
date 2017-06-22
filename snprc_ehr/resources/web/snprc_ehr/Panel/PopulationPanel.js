/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * @cfg filterArray
 * @cfg colFields
 * @cfg rowField
 */
Ext4.define('SNPRC_EHR.panel.PopulationPanel', {
    extend: 'EHR.panel.PopulationPanel',
    alias: 'widget.snprc-ehr-populationpanel',
    statics: {
        FIELDS: {
            species: 'species/arc_species_code/'
        }
    },

    loadData: function(){
        var multi = new LABKEY.MultiRequest();
        multi.add(LABKEY.Query.selectRows, {
            requiredVersion: 9.1,
            schemaName: 'study',
            queryName: 'demographics',
            filterArray: this.filterArray,
            columns: ['Id', EHR.panel.PopulationPanel.FIELDS.ageclass, EHR.panel.PopulationPanel.FIELDS.gender, SNPRC_EHR.panel.PopulationPanel.FIELDS.species].join(','),
            failure: LDK.Utils.getErrorCallback(),
            scope: this,
            success: this.doAggregation
        });

        multi.send(this.onLoad, this);
    }
});