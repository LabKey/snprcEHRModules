/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 5/30/2017.
 */
Ext4.define("LookupSetValuesStore", {
    extend: 'Ext.data.Store',
    fields: ['rowid', 'value', 'title', 'description', 'set_name', 'category'],
    autoLoad: false,
    proxy: {
        type: 'ajax',
        api: {
            read: LABKEY.ActionURL.buildURL("RelatedTables", "GetLookupSetValues"),
            update: LABKEY.ActionURL.buildURL("RelatedTables", "UpdateLookupSetValues"),
            create: LABKEY.ActionURL.buildURL("RelatedTables", "UpdateLookupSetValues"),
            destroy: LABKEY.ActionURL.buildURL("RelatedTables", "DeleteLookupSetValues")
        },
        reader: {
            type: 'json',
            root: 'values'
        },
        writer: {
            type: 'json',
            root: 'values'
        }
    },

    setLookupSetName: function (value) {
        this.lookupSet = value;
    },

    getLookupSetName: function () {
        return this.lookupSet || null;
    }

});