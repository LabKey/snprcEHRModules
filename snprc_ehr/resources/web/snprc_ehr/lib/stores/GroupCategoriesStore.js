/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("GroupCategoriesStore", {
    extend: 'Ext.data.Store',
    model: "GroupCategoryModel",
    autoLoad: true,
    remoteSort: true,
    remoteFilter: true,
    listeners: {
        load: function () {
            if (Ext4.getCmp('group-categories-grid-panel').getStore().count()) {
                Ext4.getCmp('group-categories-grid-panel').getSelectionModel().select(0);
            }
            else {
                Ext4.getCmp('group-category-form-panel').getForm().reset();
                Ext4.getCmp('groups-grid-panel').getStore().loadData([], false);
            }
            Ext4.getCmp('categories-grid-filter').focus();

        }
    }

});
