/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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
            var component = Ext4.getCmp('group-categories-grid-panel');
            if (component !== undefined) {

                if (Ext4.getCmp('group-categories-grid-panel').getStore().count()) {
                    Ext4.getCmp('group-categories-grid-panel').getSelectionModel().select(0);
                }
                else {
                    Ext4.getCmp('group-category-form-panel').getForm().reset();
                    Ext4.getCmp('groups-grid-panel').getStore().loadData([], false);
                }
            }

        }
    }

});
