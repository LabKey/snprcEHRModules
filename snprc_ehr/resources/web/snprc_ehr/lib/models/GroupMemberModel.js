/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("GroupMemberModel", {
    extend: "Ext.data.Model",
    fields: ['groupid', 'id', 'date', 'enddate'],
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
