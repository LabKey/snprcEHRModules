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

                this.updateGrids(filter);

            }

        }
    },
    initComponent: function () {
        this.getStore().load();
        this.callParent(arguments);
    },

    /**
     *
     * @returns an array of sections, each containing an array of tab configs
     */
    getAccordionSectionsAndTabs: function () {

        var sectionsAndTabs = [
            {
                sectionTitle: 'Assignment And Groups',
                tabs: [
                    {
                        config: {
                            title: 'Account Assignments',
                            schemaName: 'study',
                            queryName: 'animalAccounts'
                        }
                    },
                    {
                        config: {
                            title: 'Active Assignment',
                            schemaName: 'study',
                            queryName: 'demographicsActiveAssignment'

                        }
                    },
                    {
                        config: {
                            title: 'Assignment History',
                            schemaName: 'study',
                            queryName: 'assignment'

                        }
                    },
                    {
                        config: {
                            title: 'Breeding Group Assignments',
                            schemaName: 'study',
                            queryName: 'breedingGrpAssignments'

                        }
                    },
                    {
                        config: {
                            title: 'Colony Assignments',
                            schemaName: 'study',
                            queryName: 'assignmentCoAssignedAnimals'

                        }
                    }
                ]
            },
            {
                sectionTitle: 'Behavior',
                tabs: []
            },
            {
                sectionTitle: 'Clinical',
                tabs: [
                    {
                        config: {
                            title: 'Adm History',
                            schemaName: 'study',
                            queryName: 'cases'
                        }
                    },
                    {
                        config: {
                            title: 'Animal Events',
                            schemaName: 'study',
                            queryName: 'encounters'

                        }
                    },
                    {
                        config: {
                            title: 'Clinical History',
                            schemaName: 'study',
                            queryName: 'demographics',
                            viewName: 'Snapshot'

                        }
                    },
                    {
                        config: {
                            title: 'Clinical Remarks',
                            schemaName: 'study',
                            queryName: 'Clinical Remarks'

                        }
                    },
                    {
                        config: {
                            title: 'Clinical Snapshots',
                            schemaName: 'study',
                            queryName: 'demographics',
                            viewName: 'Snapshot'

                        }
                    },
                    {
                        config: {
                            title: 'Daily Observations',
                            schemaName: 'study',
                            queryName: 'dailyObsPivot'
                        }
                    },
                    {
                        config: {
                            title: 'Procedures',
                            schemaName: 'study',
                            queryName: 'procedure'
                        }
                    },
                    {
                        config: {
                            title: 'Procedures Before Dispositions',
                            schemaName: 'study',
                            queryName: 'encounters',
                            viewName: 'ProceduresBeforeDisposition'

                        }
                    },
                    {
                        config: {
                            title: 'Therapies',
                            schemaName: 'study',
                            queryName: 'Treatment Orders',
                            viewName: 'Therapies'

                        }
                    }
                ]
            },
            {
                sectionTitle: 'Colony Management',
                tabs: [
                    {
                        config: {
                            title: 'Birth Records',
                            schemaName: 'study',
                            queryName: 'birth'
                        }
                    },
                    {
                        config: {
                            title: 'Cage Mate History',
                            schemaName: 'study',
                            queryName: 'housingRoomMates'

                        }
                    },
                    {
                        config: {
                            title: 'Death Records',
                            schemaName: 'study',
                            queryName: 'deaths'

                        }
                    },
                    {
                        config: {
                            title: 'Housing - Active',
                            schemaName: 'study',
                            queryName: 'housing',
                            viewName: 'Active Housing'

                        }
                    },
                    {
                        config: {
                            title: 'Housing History',
                            schemaName: 'study',
                            queryName: 'housing'

                        }
                    },
                    {
                        config: {
                            title: 'Weights',
                            schemaName: 'study',
                            queryName: 'weight'
                        }
                    }
                ]
            },
            {
                sectionTitle: 'General',
                tabs: [
                    {
                        config: {
                            title: 'Acquisition and Disposition',
                            schemaName: 'study',
                            queryName: 'acq_dispHistory'
                        }
                    },
                    {
                        config: {
                            title: 'Blood Draws History',
                            schemaName: 'study',
                            queryName: 'Blood Draws'

                        }
                    },
                    {
                        config: {
                            title: 'Clinical History',
                            schemaName: 'study',
                            queryName: 'demographics',
                            viewName: 'Snapshot'

                        }
                    },
                    {
                        config: {
                            title: 'Current Blood',
                            schemaName: 'study',
                            queryName: 'demographics',
                            viewName: 'Blood Draws'

                        }
                    },
                    {
                        config: {
                            title: 'Demographics',
                            schemaName: 'study',
                            queryName: 'demographics',
                            viewName: 'By Location'

                        }
                    },
                    {
                        config: {
                            title: 'Diet History',
                            schemaName: 'study',
                            queryName: 'dietHistory',
                            viewName: 'dietHistory'
                        }
                    },
                    {
                        config: {
                            title: 'Freezer/Sample Data',
                            schemaName: 'study',
                            queryName: 'Freezerworks'
                        }
                    },
                    {
                        config: {
                            title: 'ID History',
                            schemaName: 'study',
                            queryName: 'idHistory'
                        }
                    },
                    {
                        config: {
                            title: 'Snapshot',
                            schemaName: 'study',
                            queryName: 'demographics',
                            viewName: 'Snapshot'
                        }
                    },
                    {
                        config: {
                            title: 'TB Test Results',
                            schemaName: 'study',
                            queryName: 'tb'
                        }
                    }
                ]
            },
            {
                sectionTitle: 'Genetics',
                tabs: [
                    {
                        config: {
                            title: 'Inbreeding Coefficients',
                            schemaName: 'study',
                            queryName: 'Inbreeding Coefficients'
                        }
                    },
                    {
                        config: {
                            title: 'Kinship',
                            schemaName: 'ehr',
                            queryName: 'kinship'

                        }
                    },
                    {
                        config: {
                            title: 'Pedigree',
                            schemaName: 'study',
                            queryName: 'demographicsFamily'
                        }
                    },
                    {
                        config: {
                            title: 'Pedigree Plot',
                            schemaName: 'study',
                            queryName: 'pedigree'
                        }
                    }
                ]
            },
            {
                sectionTitle: 'Lab Results',
                tabs: [
                    {
                        config: {
                            title: 'Biochemistry',
                            schemaName: 'study',
                            queryName: 'chemPivot'
                        }
                    },
                    {
                        config: {
                            title: 'Hematology',
                            schemaName: 'study',
                            queryName: 'hematologyPivot'

                        }
                    },
                    {
                        config: {
                            title: 'Lab Runs',
                            schemaName: 'study',
                            queryName: 'Clinpath Runs'
                        }
                    },
                    {
                        config: {
                            title: 'Surveillance',
                            schemaName: 'study',
                            queryName: 'surveillancePivot'
                        }
                    }
                ]
            },
            {
                sectionTitle: 'Pathology',
                tabs: [
                    {
                        config: {
                            title: 'Clinical History - Full',
                            schemaName: 'study',
                            queryName: 'demographics',
                            viewName: 'Snapshot'
                        }
                    }
                ]
            },
            {
                sectionTitle: 'Reproductive Management',
                tabs: [
                    {
                        config: {
                            title: 'Birth Records',
                            schemaName: 'study',
                            queryName: 'birth'
                        }
                    },
                    {
                        config: {
                            title: 'Breeding Group Assignment',
                            schemaName: 'study',
                            queryName: 'breedingGrpAssignments'

                        }
                    },
                    {
                        config: {
                            title: 'Cycle History',
                            schemaName: 'study',
                            queryName: 'Clinpath Runs'
                        }
                    },
                    {
                        config: {
                            title: 'Offspring',
                            schemaName: 'study',
                            queryName: 'demographicsOffspring'
                        }
                    },
                    {
                        config: {
                            title: 'Pregnancy History',
                            schemaName: 'study',
                            queryName: 'pregnancyHistory'
                        }
                    }
                ]
            },
            {
                sectionTitle: 'Surgery',
                tabs: [
                    {
                        config: {
                            title: 'Procedure Summary',
                            schemaName: 'study',
                            queryName: 'proceduresPerYear'
                        }
                    }
                ]
            }
        ];


        return sectionsAndTabs;
    },

    getPreviousSelectedItem: function () {
        return this.previousSelectedItem || null;
    },
    setPreviousSelectedItem: function (itemId) {
        this.previousSelectedItem = itemId;
    },

    updateGrids: function (filter) {
        var gridsContainer = Ext4.getCmp('animals-by-location-ldk-grids-container');

        gridsContainer.items.each(function (item) {
            item.removeAll(true);
        });

        for (var i = 0; i < this.getAccordionSectionsAndTabs().length; i++) {
            var section = this.getAccordionSectionsAndTabs()[i];
            for (var j = 0; j < section.tabs.length; j++) {
                var tab = section.tabs[j].config;
                var queryTab = Ext4.create('LDK.panel.QueryPanel', {
                    title: tab.title,
                    overflowY: 'auto',
                    queryConfig: LDK.Utils.getReadOnlyQWPConfig({
                        title: tab.title,
                        schemaName: tab.schemaName,
                        queryName: tab.queryName,
                        viewName: tab.viewName || '',
                        allowHeaderLock: false,
                        filters: [filter]
                    })
                });

                gridsContainer.items.items[i].add(queryTab);

            }


        }

        gridsContainer.doLayout();

    }


});
