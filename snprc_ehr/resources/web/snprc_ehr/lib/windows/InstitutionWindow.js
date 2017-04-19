/**
 * Created by lkacimi on 4/14/2017.
 */
Ext4.define("InstitutionWindow", {
    extend: "Ext.window.Window",
    modal: true,
    title: "Edit/Add Institution",
    width: 550,
    id: 'institution-window',
    resizable: false,
    items: [
        {
            xtype: 'institution-form-panel'
        }
    ]
});
