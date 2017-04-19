/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("GroupCategoryModel", {
    extend: "Ext.data.Model",
    fields: [
        {
            name: 'categoryCode'
        },
        {
            name: 'description',
            allowBlank: false
        },
        {
            name: 'comment'
        },
        {
            name: 'displayable',
            allowBlank: false
        },
        {
            name: 'species'
        },
        {
            name: 'sex'
        },
        {
            name: 'enforceExclusivity',
            allowBlank: false
        },
        {
            name: 'allowFutureDate',
            allowBlank: false
        }],
    idProperty: "categoryCode",
    proxy: {
        type: 'ajax',
        api: {
            create: LABKEY.ActionURL.buildURL("AnimalGroups", "UpdateCategories"),
            read: LABKEY.ActionURL.buildURL("AnimalGroups", "GetCategories"),
            update: LABKEY.ActionURL.buildURL("AnimalGroups", "UpdateCategories"),
            destroy: LABKEY.ActionURL.buildURL("AnimalGroups", "RemoveCategory")

        },
        reader: {
            type: 'json',
            root: 'rows'
        }
    }
});
