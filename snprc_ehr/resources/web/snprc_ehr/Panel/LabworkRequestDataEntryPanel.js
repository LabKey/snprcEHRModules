/*
 * Copyright (c) 2016-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('SNPRC_EHR.panel.LabworkRequestDataEntryPanel', {
    extend: 'EHR.panel.RequestDataEntryPanel',
    alias: 'widget.snprc-labworkrequestdataentrypanel',

    onStoreCollectionCommitComplete: function(sc, extraContext){
        if (Ext4.Msg.isVisible())
            Ext4.Msg.hide();

        this.callParent(arguments);
    }
});