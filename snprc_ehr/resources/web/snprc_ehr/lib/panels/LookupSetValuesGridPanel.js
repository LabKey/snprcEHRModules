/**
 * Created by lkacimi on 5/30/2017.
 */
Ext4.define("LookupSetValuesGridPanel", {
    extend: 'Ext.grid.Panel',
    alias: 'widget.lookup-set-values-grid-panel',
    id: 'lookup-set-values-grid-panel',
    store: Ext4.create('LookupSetValuesStore'),
    marginTop: 25,
    height: 600,
    setType: 'cellmodel',
    plugins: [
        {
            ptype: 'cellediting',
            clicksToEdit: 2
        }
    ],
    tbar: [
        {
            text: "Add",
            iconCls: 'add-btn',
            handler: function () {
                var store = this.up('grid').getStore();

                if (store.getLookupSetName()) {
                    rec = store.add([{rowid: 0, set_name: store.getLookupSetName()}]);
                    this.up('grid').getView().select(rec, true, true);
                }
                else {
                    Ext4.Msg.alert("Error", "Select lookup set first");
                }

            }
        }
    ],
    columns: [
        {
            text: 'rowid',
            dataIndex: 'rowid',
            hidden: true,
            hideable: false

        },
        {
            text: 'set Name',
            dataIndex: 'set_name',
            hidden: true,
            hideable: false

        }, {
            text: 'Value',
            dataIndex: 'value',
            minWidth: 200,
            editor: {
                xtype: 'textfield'
            }
        }, {
            text: 'Description',
            flex: 1,
            autoSizeColumn: true,
            dataIndex: 'description',
            editor: {
                xtype: 'textfield'
            },
            allowBlank: false
        },
        {
            text: 'Title',
            dataIndex: 'title',
            minWidth: 200,
            editor: {
                xtype: 'textfield'
            }
        }, {
            text: 'Category',
            dataIndex: 'category',
            minWidth: 200,
            editor: {
                xtype: 'textfield'
            }
        }, {

            header: 'Actions',
            xtype: 'actioncolumn',
            items: [
                {
                    tooltip: 'Delete',
                    handler: function (grid, rowIndex, colIndex, item, e, record) {
                        var grid = this.up('grid');

                        Ext4.MessageBox.confirm('Confirm', 'Are you sure you want to do this ?', function (btn) {
                            if (btn == 'yes') {
                                grid.getStore().removeAt(rowIndex);
                                grid.getStore().sync({
                                    failure: function () {
                                        grid.getStore().load({
                                            params: {
                                                'lookupSetName': grid.getStore().getLookupSetName()
                                            }
                                        });
                                        Ext4.Msg.alert('Error', 'Unable to delete this value');
                                    },
                                });
                            }
                        });


                    },
                    iconCls: "trash-btn"

                }
            ]
        }
    ],
    buttons: [
        {
            text: 'Submit',
            handler: function () {
                var self = this;
                this.up('grid').getStore().save({
                    success: function () {
                        self.up('grid').getStore().load({
                            params: {
                                'lookupSetName': self.up('grid').getStore().getLookupSetName()
                            }

                        });
                    },
                    failure: function () {
                        Ext4.MessageBox.alert("Something went Wrong!", "Unable to add/update Value(s)");
                    }

                });


            }
        }
    ]
});
