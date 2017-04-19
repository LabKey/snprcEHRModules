/**
 * Created by lkacimi on 4/13/2017.
 */
Ext4.define("InstitutionsGridPanel", {
    extend: 'Ext.grid.Panel',
    alias: 'widget.institutions-grid-panel',
    id: 'institutions-grid-panel',
    store: Ext4.create('InstitutionsStore'),
    listeners: {
        selectionchange: function (selectionModel, selected) {

        }
    },
    tbar: Ext4.create('Ext.toolbar.Toolbar', {
        defaults: {
            listeners: {
                change: function () {
                    this.up('grid').setFilter();
                }
            }
        },
        items: [
            {
                text: "Add",
                iconCls: 'add-btn',
                handler: function () {
                    var store = this.up('grid').getStore();

                    rec = store.add(Ext4.create("InstitutionModel", {institution_id: 0}));
                    this.up('grid').getSelectionModel().select(rec, true, true);
                    this.up('grid').getSelectionModel().fireEvent('selectionchange', this.up('grid').getSelectionModel(), this.up('grid').getSelectionModel().getSelection());


                }

            },
            {
                emptyText: "Filter...",
                text: 'Filter',
                xtype: 'textfield',
                id: 'institutions-filter-by-name',
                listeners: {
                    change: function () {
                        var self = this;
                        this.up('grid').setFilter(this.getValue());


                    }
                }
            },
            {
                xtype: 'combo',
                store: Ext4.create('StatesStore'),
                fieldLabel: 'State:',
                labelWidth: 40,
                width: 200,
                padding: 5,
                id: 'institutions-filter-by-state',
                valueField: 'code',
                displayField: 'name',
                typeAhead: true,
                queryMode: 'local'

            },
            {
                text: 'Reset',
                iconCls: 'reset-btn',
                handler: function () {
                    Ext4.getCmp('institutions-filter-by-name').reset();
                    Ext4.getCmp('institutions-filter-by-state').reset();
                }
            }
        ]
    }),


    columns: [
        {
            text: 'ID',
            dataIndex: 'institutionId',

        }, {
            text: 'Name',
            dataIndex: 'institutionName',
            minWidth: 350
        }, {
            text: 'Short Name',
            dataIndex: 'shortName',

        }, {
            text: 'City',
            dataIndex: 'city',
            minWidth: 150
        }, {
            text: 'State',
            dataIndex: 'state'
        }, {
            text: 'Affiliate',
            dataIndex: 'affiliate',
            minWidth: 150,
            flex: 1,
            autoSizeColumn: true
        }, {
            text: 'Web Site',
            dataIndex: 'webSite',
            minWidth: 150,

        }, {

            header: 'Actions',
            xtype: 'actioncolumn',
            items: [
                {
                    tooltip: 'Edit Institution',
                    handler: function (grid, rowIndex, colIndex, item, e, record) {
                        var institutionWindow = Ext4.create('InstitutionWindow');
                        institutionWindow.down('form').loadRecord(record);
                        institutionWindow.show();

                    },
                    iconCls: "edit-btn"

                },
                {
                    tooltip: 'Delete Institution',
                    handler: function (grid, rowIndex, colIndex, item, e, record) {
                        var self = this;
                        Ext4.Msg.confirm('Confirm', 'Are you sure?', function (value) {
                            if (value == 'yes') {
                                var grid = self.up('grid');
                                grid.getStore().removeAt(rowIndex);
                                record.destroy({
                                    failure: function () {
                                        Ext4.Msg.alert("Error", "Unable to delete institution");
                                        grid.getStore().load();
                                    }
                                });
                            }

                        });
                    },
                    iconCls: "trash-btn"

                },
                {
                    tooltip: 'View Website',
                    handler: function (grid, rowIndex, colIndex, item, e, record) {
                        var website = record.get('webSite');
                        if (website) {

                            wwwExpression = /www/
                            httpsExpression = /https:/
                            httpExpression = /http:/

                            //1. does it contain http or https?
                            if (httpExpression.test(website) || httpsExpression.test(website)) {
                                window.open(website);
                            }
                            else {
                                if (wwwExpression.test(website)) {
                                    //2. does it contain https: or http://
                                    window.open("http://" + website);

                                }
                                else {
                                    Ext4.Msg.alert("Invalid URL", "Invalid Website")
                                }

                            }


                        }
                        else {
                            Ext4.Msg.alert("No URL", "Unknown Website")
                        }

                    },
                    iconCls: "link-btn"

                }
            ]
        }
    ],

    setFilter: function () {
        this.getStore().clearFilter(true);
        this.getStore().filter([{
            property: 'institution_name',
            value: Ext4.getCmp('institutions-filter-by-name').getValue()
        }, {property: 'state', value: Ext4.getCmp('institutions-filter-by-state').getValue()}]);
    }


});