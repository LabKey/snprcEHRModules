/**
 * Created by lkacimi on 6/6/2017.
 */
Ext4.define("AnimalsByLocationReportsContainer", {
    extend: 'Ext.panel.Panel',
    alias: "widget.animals-by-location-reports-container",

    layout: {
        type: 'accordion',
        titleCollapse: true,
        animate: true
    },
    initComponent: function () {
        this.loadReports();
        this.callParent(arguments);
    },

    loadReports: function () {
        var self = this;
        Ext4.Ajax.request({
            url: LABKEY.ActionURL.buildURL("AnimalsByLocation", "GetReports"),
            method: 'POST',
            success: function (response) {
                self.reports = Ext4.decode(response.responseText);
                var sections = [];
                for (var a in self.getReports().reports) {
                    sections.push(Ext4.create("Ext.tab.Panel", {title: a, id: "report-" + a.replace(" ", '-')}));
                }
                self.add(sections);
            },
            failure: function () {
                Ext4.Msg.alert("Error", "Unable to initialize view")
            }
        });
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
        for (var section in reports) {
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

        gridsContainer.items.each(function (item) {
            item.removeAll(true);
        });

        for (var i = 0; i < this.getAccordionSectionsAndTabs().length; i++) {
            var section = this.getAccordionSectionsAndTabs()[i];
            for (var j = 0; j < section.tabs.length; j++) {
                var tab = section.tabs[j].config;
                switch (tab.type) {
                    case 'query':
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
                        break;
                    case 'js':
                        //Create a new Panel,
                        var jsPanel = Ext4.create('Ext.panel.Panel');
                        jsPanel.filters = {subjects: filter};
                        //to do
                        break;
                    case 'report':
                        //to do
                        break;
                    default:
                        //unknown report type, Skip
                }
            }


        }

        gridsContainer.doLayout();

    }
});
