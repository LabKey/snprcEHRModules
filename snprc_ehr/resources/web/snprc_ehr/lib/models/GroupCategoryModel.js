/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("GroupCategoryModel", {
    extend: "Ext.data.Model",
    fields: [
        {
            name: 'category_code'
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
            name: 'enforce_exclusivity',
            allowBlank: false
        },
        {
            name: 'allow_future_date',
            allowBlank: false
        }],
    idProperty: "category_code",
    proxy: {
        type: 'ajax',
        api: {
            create: LABKEY.ActionURL.buildURL("animalgroups", "UpdateCategories"),
            read: LABKEY.ActionURL.buildURL("animalgroups", "GetCategories"),
            update: LABKEY.ActionURL.buildURL("animalgroups", "UpdateCategories"),
            destroy: LABKEY.ActionURL.buildURL("animalgroups", "RemoveCategory")

        },
        reader: {
            type: 'json',
            root: 'rows'
        }
    }
});
