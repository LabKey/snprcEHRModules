/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("YesNoStore", {
    extend: 'Ext.data.SimpleStore',
    data: [
        ['Y', 'Yes'],
        ['N', 'No']
    ],
    id: 0,
    fields: ['value', 'text']
});