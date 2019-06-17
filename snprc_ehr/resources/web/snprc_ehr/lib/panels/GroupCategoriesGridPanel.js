/*
 * Copyright (c) 2017-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("GroupCategoriesGridPanel", {
    extend: 'Ext.grid.Panel',
    alias: 'widget.group-categories-grid-panel',
    id: 'group-categories-grid-panel',
    store: Ext4.create('GroupCategoriesStore'),
    listeners: {
        selectionchange: function (selectionModel, selected) {
            if (!selected[0]) {
                return;
            }
            var categoryCode = selected[0].get("categoryCode");
            Ext4.getCmp('group-category-form-panel').loadRecord(selected[0]);
            Ext4.getCmp('groups-grid-panel').getStore().load({
                params: {
                    'categoryCode': categoryCode
                }
            });
            Ext4.getCmp('groups-grid-panel').getStore().setCategory(categoryCode);
        },
        buffer: 10
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
                            var grid = this.up('grid');
                            var store = grid.getStore();

                            // has a row already been inserted?
                            var row = store.getRange();
                            for (var i = 0; i < row.length; i++) {

                                if (row[i].getData().categoryCode === 0) return;
                            }

                            rec = store.insert(0, Ext4.create("GroupCategoryModel", {categoryCode: 0, sortOrder: 0}));

                            grid.getSelectionModel().select(rec, true, true);
                            //var rowIndex = store.indexOf(rec);
                            grid.getView().scrollRowIntoView(0);
                            grid.getSelectionModel().fireEvent('selectionchange', grid.getSelectionModel(), grid.getSelectionModel().getSelection());
                        }

                    },

                    {
                        emptyText: "Filter...",
                        text: 'Filter',
                        xtype: 'textfield',
                        id: 'categories-filter-by-description'
                    },
                    {
                        xtype: 'combo',
                        store: Ext4.create('SpeciesStore'),
                        fieldLabel: 'Species:',
                        labelWidth: 50,
                        width: 300,
                        padding: 5,
                        id: 'categories-filter-by-species',
                        valueField: 'arcSpeciesCode',
                        displayField: 'speciesName',
                        typeAhead: true,
                        queryMode: 'local'

                    },
                    {
                        xtype: 'combo',
                        store: Ext4.create('GenderStore'),
                        id: 'filter-by-gender',
                        fieldLabel: 'Gender:',
                        labelWidth: 50,
                        width: 150,
                        padding: 5,
                        id: 'categories-filter-by-gender',
                        valueField: 'value',
                        displayField: 'text',
                        typeAhead: true,
                        queryMode: 'local'

                    },

                    {
                        text: 'Reset',
                        iconCls: 'reset-btn',
                        handler: function () {
                            Ext4.getCmp('categories-filter-by-description').reset();
                            Ext4.getCmp('categories-filter-by-species').reset();
                            Ext4.getCmp('categories-filter-by-gender').reset();
                        }
                    }
                ]
            }
    ),


    columns: [
        {
            text: 'Code',
            dataIndex: 'categoryCode',

        }, {
            text: 'Description',
            dataIndex: 'description',
            minWidth: 200
        }, {
            text: 'Comment',
            dataIndex: 'comment',
            flex: 1,
            autoSizeColumn: true
        }, {
            text: 'Displayable',
            dataIndex: 'displayable',
            renderer: function (value) {
                return value == 'Y' ? "Yes" : "No"
            },
            minWidth: 150
        }, {
            text: 'Species',
            dataIndex: 'species'
        }, {
            text: 'Sex',
            dataIndex: 'sex',
            renderer: function (value) {
                return value == 'F' ? "Female" : (value == "M" ? "Male" : value)
            },
            minWidth: 150
        }, {
            text: 'Enforce Exclusivity',
            dataIndex: 'enforceExclusivity',
            minWidth: 150,
            renderer: function (value) {
                return value == 'Y' ? "Yes" : "No";
            }
        }, {
            text: 'Allow Future Date',
            dataIndex: 'allowFutureDate',
            renderer: function (value) {
                return value == 'Y' ? "Yes" : "No"
            },
            minWidth: 150
        }, {

            header: 'Actions',
            xtype: 'actioncolumn',
            items: [
                {
                    tooltip: 'Delete Category',
                    handler: function (grid, rowIndex, colIndex, item, e, record) {
                        var grid = this.up('grid');
                        grid.getStore().removeAt(rowIndex);
                        record.destroy({
                            failure: function () {
                                Ext4.Msg.alert("Error", "Unable to delete this Category");
                                grid.getStore().load();
                            },
                            success: function () {
                                grid.view.select(1);
                            }
                        });

                    },
                    iconCls: "trash-btn"

                }
            ]
        }
    ],

    setFilter: function () {
        this.getStore().clearFilter(true);
        this.getStore().filter([{
            property: 'description',
            value: Ext4.getCmp('categories-filter-by-description').getValue()
        }, {property: 'sex', value: Ext4.getCmp('categories-filter-by-gender').getValue()}, {
            property: 'species',
            value: Ext4.getCmp('categories-filter-by-species').getValue()
        }]);

    }


});
