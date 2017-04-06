/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("GroupMemberModel", {
    extend: "Ext.data.Model",
    fields: ['groupid', 'id', 'date', 'enddate'],
    proxy: {
        type: 'ajax',
        api: {
            read: LABKEY.ActionURL.buildURL("animalgroups", "GetAnimalsByGroup"),
            update: LABKEY.ActionURL.buildURL("animalgroups", "UpdateGroupMembers"),
            create: LABKEY.ActionURL.buildURL("animalgroups", "UpdateGroupMembers"),
            destroy: LABKEY.ActionURL.buildURL("animalgroups", "DeleteGroupMembers")
        },
        reader: {
            type: 'json',
            root: 'animals'
        }

    }
});
