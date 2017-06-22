/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/14/2017.
 */
/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("StatesStore", {
    extend: 'Ext.data.Store',
    fields: ['code', 'name'],
    autoLoad: true,
    proxy: {
        type: 'ajax',
        api: {
            read: LABKEY.ActionURL.buildURL("ValidInstitutions", "GetStates"),
        },
        reader: {
            type: 'json',
            root: 'states'
        }
    }
});