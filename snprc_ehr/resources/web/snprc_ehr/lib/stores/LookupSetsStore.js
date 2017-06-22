/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 5/30/2017.
 */
Ext4.define("LookupSetsStore", {
    extend: 'Ext.data.Store',
    fields: ['value', 'label'],
    autoLoad: true,
    proxy: {
        type: 'ajax',
        api: {
            read: LABKEY.ActionURL.buildURL("RelatedTables", "GetLookupSets"),
        },
        reader: {
            type: 'json',
            root: 'sets'
        }
    }
});