/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("GenderStore", {
    extend: 'Ext.data.SimpleStore',
    data: [
        ['', 'N/A'],
        ['M', 'Male'],
        ['F', 'Female']
    ],
    id: 0,
    fields: ['value', 'text']
});