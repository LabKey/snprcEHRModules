/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created to allow a custom row editor plugin and column that summarize observations
 */
Ext4.define('SNPRC_EHR.grid.ClinicalObservationGridPanel', {
    extend: 'EHR.grid.Panel',
    alias: 'widget.snprc_ehr-clinicalobservationgridpanel',

    initComponent: function(){
        //this.observationTypesStore = EHR.DataEntryUtils.getObservationTypesStore();

        this.callParent(arguments);
    },

    //getEditingPlugin: function(){
    //    LDK.Assert.assertNotEmpty('this.observationTypesStore is null in ClinicalObservationsGridPanel', this.observationTypesStore);
    //
    //    return Ext4.create('SNPRC_EHR.grid.plugin.ClinicalObservationsCellEditing', {
    //        pluginId: this.editingPluginId,
    //        clicksToEdit: this.clicksToEdit,
    //        observationTypesStore: EHR.DataEntryUtils.getObservationTypesStore()
    //    });
    //}
});