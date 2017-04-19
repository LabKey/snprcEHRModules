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