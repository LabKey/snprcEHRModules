/**
 * Created by lkacimi on 4/11/2017.
 */
/*
 Ext4.define("AnimalModel",{
 extend:'Ext.data.Model',
 fields:['text']
 });

 Ext4.define("LocationModel",{
 extend:'Ext.data.Model',
 fields:['text'],
 hasMany:[{name:'children',model:'LocationModel'}]
 });
 */
Ext4.define("AnimalsByLocationTreeStore", {
    extend: "Ext.data.TreeStore",
    fields: ['id', 'text', 'sex', 'leaf', 'cls', 'iconCls'],
    autoLoad: true,
    defaultRootId: '',
    proxy: {
        type: 'ajax',
        url: LABKEY.ActionURL.buildURL("AnimalsByLocation", "GetHierarchy"),
        reader: {
            type: 'json',
            idProperty: 'id',
            root: 'nodes'
        }
    }
});
