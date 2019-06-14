/*
 * Copyright (c) 2017-2019 LabKey Corporation
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
    height: 600,
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
                        var reportsContainerPanel = Ext4.getCmp('animals-by-node-ldk-grids-container');
                        reportsContainerPanel.setCurrentCriteria("Animal " + rec.get('text'));
                        reportsContainerPanel.setFilter(filter);
                        reportsContainerPanel.setUpdating(true);
                        reportsContainerPanel.updateGrid(filter,
                                reportsContainerPanel.getSectionIndex(),
                                reportsContainerPanel.items.items[reportsContainerPanel.getSectionIndex()].getActiveTabIndex(),
                                reportsContainerPanel.items.items[reportsContainerPanel.getSectionIndex()].getActiveTab());
                        reportsContainerPanel.setUpdating(false);
                        break;
                    case 'location':
                    case 'protocol':
                    case 'group':
                    case 'category':
                        //ajax call to retrieve all animals assigned/belonging to node
                        var self = this;
                        var reportsContainerPanel = Ext4.getCmp('animals-by-node-ldk-grids-container');
                        reportsContainerPanel.up().setLoading(true);
                        Ext4.Ajax.request({
                            url: LABKEY.ActionURL.buildURL("AnimalsHierarchy", "getAnimals"),
                            method: 'POST',
                            params: {
                                value: rec.get('id'),
                                by: rec.get('cls'),
                                includeAllAnimals: self.getStore().getProxy().extraParams.includeAllAnimals
                            },
                            success: function (response) {
                                var animalsArray = Ext4.decode(response.responseText);
                                animalsArray = animalsArray.animals;
                                var animalsIds = [];
                                if (!animalsArray.length) {
                                    reportsContainerPanel.up().setLoading(false);
                                    Ext4.Msg.alert('Error', 'No Animals');
                                    return;
                                }
                                for (var i = 0; i < animalsArray.length; i++) {
                                    animalsIds.push(animalsArray[i].text);
                                }


                                filter = LABKEY.Filter.create('id', animalsIds.join(';'), LABKEY.Filter.Types.IN);


                                reportsContainerPanel.setCurrentCriteria("Animals assigned to " + rec.get('cls') + " " + rec.get('text'));
                                reportsContainerPanel.setFilter(filter);
                                reportsContainerPanel.setUpdating(true);
                                reportsContainerPanel.updateGrid(filter,
                                        reportsContainerPanel.getSectionIndex(),
                                        reportsContainerPanel.items.items[reportsContainerPanel.getSectionIndex()].getActiveTabIndex(),
                                        reportsContainerPanel.items.items[reportsContainerPanel.getSectionIndex()].getActiveTab());
                                reportsContainerPanel.setUpdating(false);
                                reportsContainerPanel.up().setLoading(false);

                            },
                            failure: function () {

                            }
                        });

                        break;
                }

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
