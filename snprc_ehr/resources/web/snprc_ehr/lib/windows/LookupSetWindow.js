/**
 * Created by lkacimi on 6/1/2017.
 */

Ext4.define('LookupSetWindow', {
    extend: "Ext.window.Window",
    alias: "widget.lookup-set-window",
    bodyStyle: 'padding:5px 5px 0',
    labelWidth: 450,
    defaults: {width: 600},
    items: [
        {
            xtype: 'form',
            items: [
                {
                    xtype: 'textfield',
                    name: 'lookupSetName',
                    fieldLabel: 'Lookup Set',
                    hidden: true,

                },
                {
                    xtype: 'textfield',
                    name: 'lookupSetLabel',
                    fieldLabel: 'Label',
                    allowBlank: false,
                    width: 500
                }
            ],
            buttons: [
                {
                    text: 'Submit',
                    handler: function () {

                        var form = this.up('form');
                        form.updateRecord(this.up('form').getRecord());
                        if (!this.up('form').isValid()) {
                            return;
                        }
                        var window = this.up('window');

                        Ext4.Ajax.request({
                            url: LABKEY.ActionURL.buildURL("RelatedTables", "UpdateLookupSet"),
                            method: 'POST',
                            params: form.getForm().getValues(),
                            success: function () {
                                //Update/Save is successful, select the combobox, relaod the store and select the added/updated lookup set
                                var lookupSetCombo = Ext4.getCmp("lookupSetsCombo");
                                lookupSetCombo.getStore().load({
                                    callback: function () {
                                        var obj = form.getForm().getValues();
                                        if (obj.lookupSetName != '') {
                                            lookupSetCombo.setValue(obj.lookupSetName);
                                        }
                                        else {
                                            lookupSetCombo.setValue(obj.lookupSetLabel.replace(" ", "_"));
                                        }
                                        lookupSetCombo.fireEvent("select");

                                        window.close();

                                    }
                                });


                            },
                            failure: function () {

                                Ext4.Msg.alert("Error", "Unable to Save/Update Lookup Set")
                            }
                        });

                    }
                },
                {
                    text: "Cancel",
                    handler: function () {
                        this.up('window').close();
                    }
                }
            ]
        }
    ]


});
