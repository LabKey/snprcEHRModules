/*
 * Copyright (c) 2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 6/6/2017.
 */
Ext4.define("AnimalsByNodeReportsContainer", {
    extend: 'Ext.panel.Panel',
    alias: "widget.animals-by-node-reports-container",

    /*layout: {
        type: 'accordion',
        titleCollapse: true,
        animate: true
     },*/
    autScroll: true,
    height: 735,
    overflowY: 'scroll',
    initComponent: function () {
        this.loadReports();
        this.callParent(arguments);
    },

    showSection: function (sectionTitle) {
        this.items.each(function (item, index) {
            if (index != 0) {
                switch (item.title) {
                    case sectionTitle:
                        item.show();
                        break;
                    default:
                        item.hide();
                }
            }

        });
    },
    loadReports: function () {
        var self = this;
        Ext4.Ajax.request({
            url: LABKEY.ActionURL.buildURL("AnimalsHierarchy", "GetReports"),
            method: 'POST',
            success: function (response) {
                self.reports = Ext4.decode(response.responseText);

                var sections = [];
                keys = [];
                for (var a in self.getReports().reports) {
                    keys.push(a);
                }
                keys.sort();

                var sectionRadios = [];
                var first = true;
                for (var a in keys) {


                    if (Ext4.isFunction(keys[a])) {
                        continue;
                    }

                    sectionRadios.push({
                        xtype: 'radio',
                        boxLabel: keys[a],
                        name: 'activeSection',
                        inputValue: keys[a],
                        style: 'margin:5px 30px 5px 5px',
                        checked: first,
                        listeners: {
                            change: function (checkBox, newValue, oldValue) {
                                if (newValue == true) {
                                    self.showSection(checkBox.boxLabel);
                                }
                            }
                        }
                    });
                    sections.push(Ext4.create("Ext.tab.Panel", {
                        title: keys[a],
                        id: "report-" + keys[a].replace(" ", '-'),
                        itemId: keys[a],
                        hidden: !first,
                        autoScroll: true,
                        listeners: {
                            'tabchange': function (tabPanel, tab) {
                                if (!tabPanel.up().isUpdating()) {
                                    tabPanel.setActiveTabIndex(tabPanel.items.indexOf(tab));

                                }
                            }

                        },

                        getTabsCount: function () {
                            return this.tabsCount;
                        },

                        setTabsCount: function (tabsCount) {
                            this.tabsCount = tabsCount;
                        },

                        setActiveTabIndex: function (activeTab) {
                            this.activeTabIndex = activeTab;
                        },

                        getActiveTabIndex: function () {
                            return this.activeTabIndex || 0;
                        }

                    }));

                    first = false;

                }
                self.add(Ext4.create("Ext.form.Panel", {
                    layout: 'hbox',
                    items: sectionRadios
                }));

                self.add(sections);
            },
            failure: function () {
                Ext4.Msg.alert("Error", "Unable to initialize view");
            }
        });
    },

    setUpdating: function (value) {
        this.updating = value;
    },

    isUpdating: function () {
        return this.updating || false;
    },

    getReports: function () {
        return this.reports;
    },

    /**
     *
     * @returns an array of sections, each containing an array of tab configs
     */
    getAccordionSectionsAndTabs: function () {
        var sectionsAndTabs = [];
        var reports = this.getReports().reports;
        keys = [];
        for (var a in reports) {
            keys.push(a);
        }
        keys.sort();
        for (var s in keys) {
            if (!keys.hasOwnProperty(s)) {
                continue;
            }
            var section = keys[s];
            var oneSectionTabs = {};
            oneSectionTabs.sectionTitle = section;
            oneSectionTabs.tabs = [];
            for (var i = 0; i < reports[section].length; i++) {
                oneSectionTabs.tabs.push({
                    config: {
                        title: reports[section][i]['title'],
                        schemaName: reports[section][i]['schemaName'],
                        queryName: reports[section][i]['queryName'],
                        viewName: reports[section][i]['viewName'],
                        type: reports[section][i]['type']
                    }
                });
            }
            sectionsAndTabs.push(oneSectionTabs);
        }


        return sectionsAndTabs;
    },
    updateGrids: function (filter) {
        var gridsContainer = this;

        gridsContainer.items.each(function (item, index) {
            if (index != 0) {
                item.removeAll(true);
            }

        });

        for (var i = 0; i < this.getAccordionSectionsAndTabs().length; i++) {
            var section = this.getAccordionSectionsAndTabs()[i];
            var tabsCount = 0;
            for (var j = 0; j < section.tabs.length; j++) {
                var tabConfig = section.tabs[j].config;
                switch (tabConfig.type) {
                    case 'query':
                        var queryConfig = {
                            title: tabConfig.title,
                            schemaName: tabConfig.schemaName,
                            queryName: tabConfig.queryName,
                            suppressRenderErrors: true,
                            allowChooseQuery: false,
                            allowChooseView: true,
                            showInsertNewButton: false,
                            showDeleteButton: false,
                            showDetailsColumn: true,
                            showUpdateColumn: false,
                            showRecordSelectors: true,
                            showReports: false,
                            allowHeaderLock: false,
                            tab: gridsContainer.items.items[i],
                            frame: 'portal',
                            buttonBarPosition: 'top',
                            timeout: 0,
                            filters: [filter],
                            linkTarget: '_blank',
                            success: this.onDataRegionLoad,
                            failure: LDK.Utils.getErrorCallback(),
                            scope: this
                        };

                        //special case these two properties because they are common
                        if (tabConfig.viewName) {
                            queryConfig.viewName = tabConfig.viewName;
                        }
                        var queryTab = Ext4.create('LDK.panel.QueryPanel', {
                            title: tabConfig.title,
                            overflowY: 'auto',
                            queryConfig: queryConfig,
                            autoScroll: true

                        });
                        gridsContainer.items.items[i + 1].add(queryTab);
                        tabsCount++;
                        break;
                    case 'js':
                        //Create a new Panel,
                        var jsTab = Ext4.create('LDK.panel.ContentResizingPanel', {
                            title: tabConfig.title,
                            autoScroll: true
                        });
                        var jsFunction = tabConfig.queryName;
                        if (typeof this[jsFunction] == 'function') {
                            this[jsFunction](jsTab, filter);
                            gridsContainer.items.items[i + 1].add(jsTab);
                            tabsCount++;
                        }

                        break;
                    case 'report':
                        break;
                        //TO DO
                        var reportTab = Ext4.create('LDK.panel.ContentResizingPanel', {
                            minHeight: 50
                        });
                        var target = gridsContainer.items.items[i].add(reportTab);

                        this.loadReport(target, tabConfig, filter);
                        //gridsContainer.items.items[i].add(reportTab);
                        break;
                    default:
                        //unknown report type, Skip
                }

            }
            gridsContainer.items.items[i + 1].setTabsCount(tabsCount);
            gridsContainer.items.items[i + 1].setActiveTab(gridsContainer.items.items[i + 1].getActiveTabIndex());
        }


        gridsContainer.doLayout();

    },
    onDataRegionLoad: function (dr) {
        var itemWidth = dr.domId && Ext4.get(dr.domId) && Ext4.isFunction(Ext4.get(dr.domId).getSize) ? Ext4.get(dr.domId).getSize().width + 150 : 850;
        this.doResize(itemWidth);
        LABKEY.Utils.signalWebDriverTest("LDK_reportTabLoaded");
    },
    doResize: function (itemWidth) {
        var width2 = this.getWidth();
        if (itemWidth > width2) {
            this.setWidth(itemWidth);
            this.doLayout();
        }
        else if (itemWidth < width2) {
            if (this.originalWidth && width2 != this.originalWidth) {
                this.setWidth(Math.max(this.originalWidth, itemWidth));
                this.doLayout();
            }
        }
    },
    loadReport: function (tab, tabConfig, filter) {
        var filterArray = [filter];
        tab.mask('Loading...');

        var queryConfig = {
            partName: 'Report',
            renderTo: tab.renderTarget,
            suppressRenderErrors: true,
            partConfig: {
                title: tabConfig.title + ' - ' + filter.getValue(),
                schemaName: tabConfig.schemaName,
                //reportId : tabConfig.report.reportId,
                'query.queryName': tabConfig.queryName
            },
            filters: filterArray,
            success: function (result) {
                tab.unmask();
                Ext4.defer(tab.createListeners, 200, target);
                LABKEY.Utils.signalWebDriverTest("LDK_reportTabLoaded");
            },
            failure: LDK.Utils.getErrorCallback(),
            scope: this
        };

        if (filterArray.length) {
            Ext4.each(filterArray, function (filter) {
                queryConfig.partConfig[filter.getURLParameterName('query')] = filter.getURLParameterValue();
            }, this);
        }

        /*if (tab.report.containerPath){
         queryConfig.containerPath = tab.report.containerPath;
         }*/

        if (tabConfig.viewName) {
            queryConfig.partConfig.showSection = tabConfig.viewName;
        }

        new LABKEY.WebPart(queryConfig).render();
    },

    getQWPConfig: function (config) {
        var ret = {
            allowChooseQuery: false,
            allowChooseView: true,
            showRecordSelectors: true,
            suppressRenderErrors: true,
            allowHeaderLock: false,
            showReports: false,
            frame: 'portal',
            linkTarget: '_blank',
            buttonBarPosition: 'top',
            timeout: 0,
            success: this.onDataRegionLoad,
            failure: LDK.Utils.getErrorCallback(),
            scope: this,
            showInsertNewButton: false,
            showDeleteButton: false,
            showDetailsColumn: true,
            showUpdateColumn: false
        };

        if (this.allowEditing) {
            Ext4.apply(ret, {
                showInsertNewButton: true,
                showDeleteButton: true,
                showUpdateColumn: true
            });
        }

        Ext4.apply(ret, config);

        return ret;
    },
    arrivalDeparture: function (tab, filter) {

        tab.add({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom:20px;',
            queryConfig: this.getQWPConfig({
                title: 'Arrivals - ' + filter.getValue(),
                schemaName: 'study',
                queryName: 'arrival',
                filters: [filter],
                frame: true
            })
        });

        tab.add({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom:20px;',
            queryConfig: this.getQWPConfig({
                title: 'Departures - ' + filter.getValue(),
                schemaName: 'study',
                queryName: 'departure',
                filters: [filter],
                frame: true
            })
        });
    },
    kinshipSummary: function (tab, filter) {
        tab.add({
            xtype: 'ldk-webpartpanel',
            title: 'Kinship - ' + filter.getValue(),
            style: 'margin-bottom: 20px;',
            border: false,
            items: [{
                xtype: 'ehr-kinshippanel',
                style: 'padding-bottom: 20px;',
                border: false,
                filterArray: [filter]
            }]
        });
    },
    underDevelopment: function (tab, filters) {
        tab.add({
            xtype: 'panel',
            border: false,
            html: 'The site is currently under development and we expect this tab to be enabled soon.',
            bodyStyle: 'padding: 5px;',
            defaults: {
                border: false
            }
        });
    },
    pedigree: function (tab, filter) {

        tab.add({
            xtype: 'ldk-multirecorddetailspanel',
            bodyStyle: 'padding-bottom: 20px',
            store: {
                schemaName: 'study',
                queryName: 'demographicsFamily',
                filterArray: [filter]
            },
            titlePrefix: 'Parents/Grandparents',
            titleField: 'Id',
            multiToGrid: true,
            //workaround, the 'loading' mask stays visible ...?
            loadMask: {
                show: function () {
                },
                hide: function () {
                }
            }
        });

        var configOffspring = this.getQWPConfig({
            title: 'Offspring - ' + filter.getValue(),
            schemaName: 'study',
            queryName: 'demographicsOffspring',
            filters: [filter],
            frame: true
        });

        var configSibling = this.getQWPConfig({
            title: 'Siblings - ' + filter.getValue(),
            schemaName: 'study',
            queryName: 'demographicsSiblings',
            filters: [filter],
            frame: true
        });

        tab.add({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom:20px;',
            queryConfig: configOffspring
        });

        tab.add({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom:20px;',
            queryConfig: configSibling
        });
    },
    snapshot: function (tab, filter) {
        var toAdd = [];

        toAdd.push({
            xtype: 'ldk-webpartpanel',
            title: 'Overview - ' + filter.getValue(),
            items: [{
                xtype: 'ehr-snapshotpanel',
                showExtendedInformation: true,
                showActionsButton: false,
                hrefTarget: '_blank',
                border: false,
                subjectId: filter.getValue()
            }]
        });

        toAdd.push({
            border: false,
            height: 20
        });

        toAdd.push(this.renderWeightData(tab, filter.getValue()));


        tab.add(toAdd);
    },
    renderWeightData: function (tab, subject) {
        return {
            xtype: 'panel',
            items: [
                {
                    xtype: 'panel',
                    items: [
                        {
                            xtype: 'panel',
                            title: 'Weights - ' + subject,
                            style: 'margin-bottom: 20px;',
                            border: false,
                            items: [{
                                xtype: 'ehr-weightsummarypanel',
                                style: 'padding-bottom: 20px;',
                                subjectId: subject
                            }, {
                                xtype: 'ehr-weightgraphpanel',
                                itemId: 'tabArea',
                                showRawData: true,
                                border: false,
                                subjectId: subject
                            }]
                        }
                    ]
                }
            ]


        }
    },
    weightGraph: function (tab, filter) {
        tab.add(this.renderWeightData(tab, filter.getValue()));
    },
    bloodChemistry: function (tab, filter) {

        var config = panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'chemPivot',
            title: "By Panel - " + filter.getValue(),
            titleField: 'Id',
            sort: '-date',
            filters: [filter]
        });

        tab.add({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom:20px;',
            queryConfig: config
        });

        config = panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'chemMisc',
            title: "Misc Tests - " + filter.getValue(),
            titleField: 'Id',
            sort: '-date',
            filters: [filter]
        });

        tab.add({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom:20px;',
            queryConfig: config
        });

        config = panel.getQWPConfig({
            schemaName: 'study',
            queryName: 'chemistryRefRange',
            //viewName: 'Plus Ref Range',
            title: "Reference Ranges - " + filter.getValue(),
            titleField: 'Id',
            sort: '-date',
            filters: [filter]
        });

        tab.add({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom:20px;',
            queryConfig: config
        })
    },

    clinicalHistory: function (tab, filter, includeAll) {
        var minDate = includeAll ? null : Ext4.Date.add(new Date(), Ext4.Date.YEAR, -2);
        var toAdd = [];
        var s = filter.getValue();
        toAdd.push({
            html: '<span style="font-size: large;"><b>Animal: ' + s + '</b></span>',
            style: 'padding-bottom: 20px; padding-left:5px;',
            border: false
        });

        toAdd.push({
            xtype: 'ehr-smallformsnapshotpanel',
            showActionsButton: false,
            hrefTarget: '_blank',
            border: false,
            subjectId: s,
            style: 'padding-left:5px;'
        });

        toAdd.push({
            html: '<b>Chronological History:</b><hr>',
            style: 'padding-top: 5px;padding-left:5px',
            border: false
        });

        toAdd.push({
            xtype: 'ehr-clinicalhistorypanel',
            border: true,
            subjectId: s,
            autoLoadRecords: true,
            minDate: minDate,
            hrefTarget: '_blank',
            style: 'margin-bottom: 20px; padding-left:5px'
        });


        if (toAdd.length) {
            tab.add(toAdd);
        }

    },
    fullClinicalHistory: function (tab, filter) {
        this.clinicalHistory(tab, filter, true);
    },
    currentBlood: function (tab, filter) {

        tab.add({
            html: 'This report summarizes the blood available for the animals below.  ' +
            '<br><br>If there have been recent blood draws for the animal, a graph will show the available blood over time.  On the graph, dots indicate dates when either blood was drawn or a previous blood draw fell off.  The horizontal lines indicate the maximum allowable blood that can be drawn on that date.',
            border: false,
            style: 'padding:5px; padding-bottom: 20px;'
        });

        tab.add({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom: 10px;',
            queryConfig: this.getQWPConfig({
                title: 'Summary - ' + filter.getValue(),
                schemaName: 'study',
                queryName: 'Demographics',
                viewName: 'Blood Draws',
                filterArray: [filter]
            })
        });


        tab.add({
            xtype: 'snprc-bloodsummarypanel',

            subjects: [filter.getValue()]
        });

    },
    proceduresBeforeDisposition: function (tab, filter) {

        var config = this.getQWPConfig({
            schemaName: 'study',
            queryName: 'encounters',
            viewName: 'ProceduresBeforeDisposition',
            title: "Procedure Before Disposition " + filter.getValue(),
            filters: [filter],
            removeableFilters: [LABKEY.Filter.create('survivorship/survivorshipInDays', 3, LABKEY.Filter.Types.LESS_THAN_OR_EQUAL)]
        });

        tab.add({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom:20px;',
            queryConfig: config
        });
    },
    surveillance: function (tab, filter) {

        var config = this.getQWPConfig({
            schemaName: 'study',
            queryName: 'surveillancePivot',
            title: "By Panel - " + filter.getValue(),
            titleField: 'Id',
            sort: '-date',
            filters: [filter]
        });

        tab.add({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom:20px;',
            queryConfig: config
        });
    },

    bloodChemistry: function (tab, filter) {

        var config = this.getQWPConfig({
            schemaName: 'study',
            queryName: 'chemPivot',
            title: "By Panel:",
            titleField: 'Id',
            sort: '-date',
            filters: [filter]
        });

        tab.add({
            xtype: 'ldk-querypanel',
            style: 'margin-bottom:20px;',
            queryConfig: config
        });
    },
    hematology: function (tab, filter) {

        var config = this.getQWPConfig({
            schemaName: 'study',
            queryName: 'hematologyPivot',
            title: "By Panel - " + filter.getValue(),
            titleField: 'Id',
            filters: [filter],
            sort: '-date'
        });

        tab.add({
            xtype: 'ldk-querypanel',
            style: 'padding:5px; margin-bottom:20px;',
            queryConfig: config
        });
    }
});
