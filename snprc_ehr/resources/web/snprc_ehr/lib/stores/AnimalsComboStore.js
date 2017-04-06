/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("AnimalsComboStore", {
    extend: 'Ext.data.Store',
    fields: ['participantid'],
    autoLoad: false,
    proxy: {
        type: 'ajax',
        api: {
            read: LABKEY.ActionURL.buildURL("animalgroups", "GetAnimalsByName")

        },
        reader: {
            type: 'json',
            root: 'animals'
        }
    },
    setAnimal: function (animalName) {
        if (animalName && animalName.length >= 3) {
            this.load(
                    {
                        params: {
                            'participantid': animalName
                        }
                    }
            );
            this.participantid = animalName;

        }

    }
});