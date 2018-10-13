/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("GroupMemberModel", {
    extend: "Ext.data.Model",
    fields: ['groupid', 'id', {name:'date', type: 'date'} , {name: 'enddate', type: 'date'}, 'objectid'],
    proxy: {
        type: 'ajax',
        api: {
            read: LABKEY.ActionURL.buildURL("AnimalGroups", "GetAnimalsByGroup"),
            update: LABKEY.ActionURL.buildURL("AnimalGroups", "UpdateGroupMembers"),
            create: LABKEY.ActionURL.buildURL("AnimalGroups", "UpdateGroupMembers"),
            destroy: LABKEY.ActionURL.buildURL("AnimalGroups", "DeleteGroupMembers")
        },
        reader: {
            type: 'json',
            root: 'animals'
        }

    }
});
