/**
 * Created by lkacimi on 4/13/2017.
 */
Ext4.define("InstitutionModel", {
    extend: "Ext.data.Model",
    fields: [
        {
            name: 'institutionId'
        },
        {
            name: 'institutionName',
            allowBlank: false
        },
        {
            name: 'shortName',
            allowBlank: false
        },
        {
            name: 'city',
            allowBlank: false
        },
        {
            name: 'state',
            allowBlank: false
        },
        {
            name: 'affiliate'
        },
        {
            name: 'webSite'
        }
    ],
    idProperty: "institutionId",
    proxy: {
        type: 'ajax',
        api: {
            create: LABKEY.ActionURL.buildURL("ValidInstitutions", "UpdateInstitutions"),
            read: LABKEY.ActionURL.buildURL("ValidInstitutions", "GetInstitutions"),
            update: LABKEY.ActionURL.buildURL("ValidInstitutions", "UpdateInstitution"),
            destroy: LABKEY.ActionURL.buildURL("ValidInstitutions", "DeleteInstitution")

        },
        reader: {
            type: 'json',
            root: 'institutions'
        }
    }
});

