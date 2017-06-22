/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/11/2017.
 */
Ext4.define("AnimalsByLocationTreePanel", {
    extend: 'Ext.tree.Panel',
    store: Ext4.create('AnimalsByLocationTreeStore'),
    alias: 'widget.animals-by-location-tree-panel',
    id: 'locationsTree',
    rootVisible: false,
    styleHtmlContent: true,
    height: 735,

    title: "Locations",
    listeners: {
        itemclick: function (view, rec, item, index, eventObj) {
            if (rec.get('id') != this.getPreviousSelectedItem()) {
                this.setPreviousSelectedItem(rec.get('id'));
                var filter = null;
                //Set appropriate filter // room or animal id
                switch (rec.get('cls')) {
                    case 'location':
                        filter = LABKEY.Filter.create('room/room', rec.get('id'), LABKEY.Filter.Types.EQUAL);

                        //Per Terry, refresh grids on animal selection only
                        return;
                    case 'animal':
                        filter = LABKEY.Filter.create('id', rec.get('id'), LABKEY.Filter.Types.EQUAL);
                }
                var reportsContainerPanel = Ext4.getCmp('animals-by-location-ldk-grids-container');
                reportsContainerPanel.updateGrids(filter);

            }

        }
    },

    getPreviousSelectedItem: function () {
        return this.previousSelectedItem || null;
    },
    setPreviousSelectedItem: function (itemId) {
        this.previousSelectedItem = itemId;
    }
});
