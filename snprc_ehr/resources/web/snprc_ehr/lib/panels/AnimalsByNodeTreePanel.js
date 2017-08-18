/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/11/2017.
 */
Ext4.define("AnimalsByNodeTreePanel", {
    extend: 'Ext.tree.Panel',
    store: Ext4.create('AnimalsByNodeTreeStore'),
    alias: 'widget.animals-by-node-tree-panel',
    rootVisible: false,
    styleHtmlContent: true,
    height: 735,
    title: "",
    listeners: {
        itemclick: function (view, rec, item, index, eventObj) {
            if (rec.get('text') != this.getPreviousSelectedItem()) {
                this.setPreviousSelectedItem(rec.get('text'));
                var filter = null;
                //Set appropriate filter // room or animal id
                switch (rec.get('cls')) {
                    case 'animal':
                        filter = LABKEY.Filter.create('id', rec.get('text'), LABKEY.Filter.Types.EQUAL);
                        break;
                    case 'location':
                    case 'protocol':
                        //ajax call to retrieve all animals assigned/belonging to node
                        Ext4.Ajax.request({
                            url: LABKEY.ActionURL.buildURL("AnimalsHierarchy", "getAnimals"),
                            method: 'POST',
                            params: {value: rec.get('id'), by: rec.get('cls')},
                            success: function (response) {
                                var animalsArray = Ext4.decode(response.responseText);
                                animalsArray = animalsArray.animals;
                                var animalsIds = [];
                                for (var i = 0; i < animalsArray.length; i++) {
                                    animalsIds.push(animalsArray[i].text);
                                }


                                filter = LABKEY.Filter.create('id', animalsIds.join(';'), LABKEY.Filter.Types.IN);

                                var reportsContainerPanel = Ext4.getCmp('animals-by-node-ldk-grids-container');
                                reportsContainerPanel.setCurrentCriteria(rec.get('cls') + " (" + rec.get('text') + ")");
                                reportsContainerPanel.setUpdating(true);
                                reportsContainerPanel.updateGrids(filter);
                                reportsContainerPanel.setUpdating(false);

                            },
                            failure: function () {

                            }
                        });

                        return;
                    default:
                        return;

                }
                var reportsContainerPanel = Ext4.getCmp('animals-by-node-ldk-grids-container');
                reportsContainerPanel.setCurrentCriteria("Animal " + rec.get('text'));
                reportsContainerPanel.setUpdating(true);
                reportsContainerPanel.updateGrids(filter);
                reportsContainerPanel.setUpdating(false);
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
