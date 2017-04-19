/**
 * Created by lkacimi on 4/13/2017.
 */
Ext4.define("InstitutionsStore", {
    extend: 'Ext.data.Store',
    model: "InstitutionModel",
    autoLoad: true,
    remoteSort: true,
    remoteFilter: true
});
