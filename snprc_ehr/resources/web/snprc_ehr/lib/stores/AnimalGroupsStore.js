/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("AnimalGroupsStore", {
    extend: 'Ext.data.Store',
    fields: ['code', 'category_code', 'name', {name: 'date', type: 'date', submitFormat: 'Y-m-d'}, {
        name: 'enddate',
        type: 'date',
        submitFormat: 'Y-m-d'
    }, 'comment', 'sort_order'],
    autoLoad: false,
    proxy: {
        type: 'ajax',
        api: {
            read: LABKEY.ActionURL.buildURL("animalgroups", "GetGroupsByCategory"),
            update: LABKEY.ActionURL.buildURL("animalgroups", "UpdateGroups"),
            create: LABKEY.ActionURL.buildURL("animalgroups", "UpdateGroups"),
            destroy: LABKEY.ActionURL.buildURL("animalgroups", "DeleteGroups")
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