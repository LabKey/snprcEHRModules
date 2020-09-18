/*
 * Copyright (c) 2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('SNPRC_EHR.panel.EnterDataPanel', {
    extend: 'LABKEY.ext4.BootstrapTabPanel',

    additionalEnterNewSections: [],

    initComponent: function () {
        this.items = this.getItems();

        this.callParent();

        this.loadData();
    },

    loadData: function () {
        EHR.Utils.getDataEntryItems({
            includeFormElements: false,
            success: this.onLoad,
            scope: this
        });
    },

    onLoad: function (results) {
        var formMap = {};
        Ext4.each(results.forms, function (form) {
            if (form.isAvailable && form.isVisible && form.canInsert) {
                formMap[form.category] = formMap[form.category] || [];
                formMap[form.category].push({
                    name: form.label,
                    url: LABKEY.ActionURL.buildURL('ehr', 'dataEntryForm', null, {formType: form.name})
                });
            }
        }, this);

        var sectionNames = Ext4.Object.getKeys(formMap);
        sectionNames = sectionNames.sort();

        var sections = [];
        Ext4.Array.forEach(sectionNames, function (section) {
            var items = formMap[section];
            items = LDK.Utils.sortByProperty(items, 'name', false);
            sections.push({
                header: section,
                items: items
            });
        }, this);

        sections = sections.concat(this.additionalEnterNewSections);

        this.getEnterNewPanel().removeAll();
        this.getEnterNewPanel().add({
            xtype: 'ldk-navpanel',
            sections: sections
        });
    },

    getEnterNewPanel: function () {
        if (!this.enterNewPanel) {
            this.enterNewPanel = Ext4.create('Ext.panel.Panel', {
                border: false,
                items: [this.getLoadingConfig()]
            });
        }

        return this.enterNewPanel;
    },

    getLoadingConfig: function () {
        return {
            border: false,
            bodyStyle: 'background-color: transparent;',
            html: '<i class="fa fa-spinner fa-pulse"></i> loading...'
        };
    },

    getItems: function () {
        return [{
            title: 'Enter New Data',
            itemId: 'enterNew',
            items: [
                this.getEnterNewPanel()
            ]
        }, {
            title: 'My Tasks',
            itemId: 'myTasks',
            items: [{
                xtype: 'ldk-querycmp',
                queryConfig: {
                    schemaName: 'ehr',
                    queryName: 'my_tasks',
                    viewName: 'Active Tasks'
                }
            }]
        }, {
            title: 'All Tasks',
            itemId: 'allTasks',
            items: [{
                xtype: 'ldk-querycmp',
                queryConfig: {
                    schemaName: 'ehr',
                    queryName: 'tasks',
                    viewName: 'Active Tasks'
                }
            }]
        }, {
            title: 'Queues',
            itemId: 'queues',
            items: [{
                xtype: 'ldk-navpanel',
                sections: this.getQueueSections()
            }]
        }]
    },

    getQueueSections: function () {
        return [{
            header: 'My Reports',
            renderer: function (item) {
                return item;
            },
            items: [{
                xtype: 'ldk-linkbutton',
                text: 'Service Request Summary',
                linkCls: 'labkey-text-link',
                href: LABKEY.ActionURL.buildURL('ldk', 'runNotification', null, {key: 'org.labkey.snprc_ehr.notification.RequestAdminNotification'})
            }]

        }]
    }
});
