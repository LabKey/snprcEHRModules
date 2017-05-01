/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("SpeciesStore", {
    extend: 'Ext.data.Store',
    fields: ['arcSpeciesCode', 'speciesName'],
    autoLoad: true,
    proxy: {
        type: 'ajax',
        api: {
            read: LABKEY.ActionURL.buildURL("AnimalGroups", "GetSpecies")
        },
        reader: {
            type: 'json',
            root: 'species'
        }
    }
});