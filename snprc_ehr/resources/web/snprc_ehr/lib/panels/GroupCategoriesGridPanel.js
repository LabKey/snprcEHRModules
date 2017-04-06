/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("GroupCategoriesGridPanel", {
    extend: 'Ext.grid.Panel',
    alias: 'widget.group-categories-grid-panel',
    id: 'group-categories-grid-panel',
    store: Ext4.create('GroupCategoriesStore'),
    listeners: {
        cellclick: function (gridView, htmlElement, columnIndex, dataRecord) {
            if (!dataRecord) {
                return;
            }

            Ext4.getCmp('group-category-form-panel').loadRecord(dataRecord);
            Ext4.getCmp('groups-grid-panel').getStore().load({
                params: {
                    'category_code': dataRecord.get("category_code")
                }

            });
            Ext4.getCmp('groups-grid-panel').getStore().setCategory(dataRecord.get("category_code"));
        },
        selectionchange: function (selectionModel, selected) {
            if (!selected[0]) {
                return;
            }
            Ext4.getCmp('group-category-form-panel').loadRecord(selected[0]);
            Ext4.getCmp('groups-grid-panel').getStore().load({
                params: {
                    'category_code': selected[0].get("category_code")
                }

            });
            Ext4.getCmp('groups-grid-panel').getStore().setCategory(selected[0].get("category_code"));
        }
    },
    tbar: [
        {
            text: "Add",
            handler: function () {
                var store = this.up('grid').getStore();

                rec = store.add(Ext4.create("GroupCategoryModel", {category_code: 0, sort_order: 0}));
                this.up('grid').getSelectionModel().select(rec, true, true);
                this.up('grid').getSelectionModel().fireEvent('selectionchange', this.up('grid').getSelectionModel(), this.up('grid').getSelectionModel().getSelection());


            }

        },
        {
            emptyText: "Filter...",
            text: 'Filter',
            xtype: 'textfield',
            id: 'categories-grid-filter',
            listeners: {
                change: function () {
                    var self = this;
                    this.up('grid').setFilter(this.getValue());


                }
            }
        },
        {
            text: 'Reset',
            handler: function () {
                Ext4.getCmp('categories-grid-filter').reset();
            }
        }
    ],


    columns: [
        {
            text: 'Code',
            dataIndex: 'category_code',

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
                return value == 'F' ? "Female" : (value == "M" ? "Male" : "")
            },
            minWidth: 150
        }, {
            text: 'Enforce Exclusivity',
            dataIndex: 'enforce_exclusivity',
            minWidth: 150,
            renderer: function (value) {
                return value == 'Y' ? "Yes" : "No";
            }
        }, {
            text: 'Allow Future Date',
            dataIndex: 'allow_future_date',
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
                            }
                        });

                    },
                    iconCls: "trash-btn"

                }
            ]
        }
    ],

    setFilter: function (filter) {
        this.filter = filter;
        this.getStore().clearFilter(true);
        this.getStore().filter('filter', filter);

    },

    getFilter: function () {
        return this.filter || null;
    }

});
