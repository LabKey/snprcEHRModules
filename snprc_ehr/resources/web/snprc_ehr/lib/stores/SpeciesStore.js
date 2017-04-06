/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("SpeciesStore", {
    extend: 'Ext.data.Store',
    fields: ['arc_species_code', 'species_name'],
    autoLoad: true,
    proxy: {
        type: 'ajax',
        api: {
            read: LABKEY.ActionURL.buildURL("animalgroups", "GetSpecies"),
        },
        reader: {
            type: 'json',
            root: 'rows'
        }
    }
});