/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("AnimalGroupsStore", {
    extend: 'Ext.data.Store',
    fields: ['code', 'categoryCode', 'name', {name: 'date', type: 'date', submitFormat: 'Y-m-d'}, {
        name: 'endDate',
        type: 'date',
        submitFormat: 'Y-m-d'
    }, 'comment', 'sortOrder'],
    autoLoad: false,
    proxy: {
        type: 'ajax',
        api: {
            read: LABKEY.ActionURL.buildURL("AnimalGroups", "GetGroupsByCategory"),
            update: LABKEY.ActionURL.buildURL("AnimalGroups", "UpdateGroups"),
            create: LABKEY.ActionURL.buildURL("AnimalGroups", "UpdateGroups"),
            destroy: LABKEY.ActionURL.buildURL("AnimalGroups", "DeleteGroups")
        },
        reader: {
            type: 'json',
            root: 'rows'
        },
        writer: {
            type: 'json',
            root: 'rows'
        }
    },
    setCategory: function (category) {
        this.category = category;
    },
    getCategory: function () {
        return this.category || null;
    }
});