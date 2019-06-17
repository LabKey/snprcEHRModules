/*
 * Copyright (c) 2017-2019 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("AssignAnimalsToGroupWindow", {
    extend: "Ext.window.Window",
    modal: true,
    title: "Assigning Animals to Groups - ",
    alias: "widget.assign-members-panel",
    width: 680,
    id: 'assign-members-panel',
    resizable: false,
    items: [
        {
            xtype: 'panel',
            height: 250,

            layout: {
                type: 'accordion',
                titleCollapse: false,
                animate: true,
                activeOnTop: true,
                height: 300,

            },
            items: [
                {
                    xtype: 'panel',
                    title: 'One Animal',

                    items: [
                        {
                            xtype: 'form',
                            bodyStyle: 'padding:5px 5px 0',
                            labelWidth: 150,
                            defaults: {width: 450},

                            items: [
                                {
                                    xtype: 'combo',
                                    fieldLabel: 'Animal',
                                    name: 'id',
                                    valueField: 'participantid',
                                    displayField: 'participantid',
                                    store: Ext4.create('AnimalsComboStore'),
                                    queryMode: 'local',
                                    listeners: {
                                        change: function (combo, value) {
                                            this.getStore().setAnimal(value);
                                        }
                                    },
                                    allowBlank: false

                                },
                                {
                                    xtype: 'datefield',
                                    fieldLabel: 'Start Date',
                                    name: 'date',
                                    allowBlank: false

                                },
                                {
                                    xtype: 'datefield',
                                    name: 'enddate',
                                    fieldLabel: 'End Date'
                                }
                            ],
                            buttons: [
                                {
                                    text: 'Assign',
                                    handler: function () {
                                        if (!this.up('form').isValid()) {
                                            return;
                                        }

                                        var memberRecord = Ext4.create("GroupMemberModel", {
                                            groupid: this.up('window').getGroup(),
                                            id: this.up('form').getValues()['id'],
                                            date: this.up('form').getValues()['date'],
                                            enddate: this.up('form').getValues()['enddate']
                                        });
                                        var groupId = this.up('window').getGroup();
                                        var activeOnly = this.up('window').getActiveOnly();
                                        var formPanel = this.up('form');
                                        memberRecord.save({
                                            callback: function (record, action) {
                                                if (action.success) {
                                                    Ext4.getCmp('group-members-grid').getStore().load({
                                                        params: {
                                                            groupid: groupId,
                                                            activeOnly: activeOnly
                                                        }
                                                    })

                                                    formPanel.getForm().reset();
                                                }
                                                else {
                                                        Ext4.Msg.alert("Update Failure", "<br><strong>" + action.error + "</strong> ");
                                                    }
                                            }
                                        });
                                    }
                                }
                            ]
                        }
                    ]
                },
                {
                    xtype: 'panel',
                    title: 'Multiple Animals',
                    items: [
                        {
                            xtype: 'form',
                            bodyStyle: 'padding:5px 5px 0',
                            labelWidth: 150,
                            defaults: {width: 450},

                            items: [
                                {
                                    xtype: 'textareafield',
                                    fieldLabel: 'Animals',
                                    name: 'id',
                                    allowBlank: false
                                },
                                {
                                    xtype: 'datefield',
                                    fieldLabel: 'Start Date',
                                    name: 'date',
                                    allowBlank: false

                                },
                                {
                                    xtype: 'datefield',
                                    name: 'enddate',
                                    fieldLabel: 'End Date'
                                }
                            ],
                            buttons: [
                                {
                                    text: 'Assign',
                                    handler: function () {
                                        if (!this.up('form').isValid()) {
                                            return;
                                        }

                                        var memberRecord = Ext4.create("GroupMemberModel", {
                                            groupid: this.up('window').getGroup(),
                                            id: this.up('form').getValues()['id'],
                                            date: this.up('form').getValues()['date'],
                                            enddate: this.up('form').getValues()['enddate']
                                        });
                                        var groupId = this.up('window').getGroup();
                                        var activeOnly = this.up('window').getActiveOnly();
                                        var formPanel = this.up('form');
                                        memberRecord.save({
                                            callback: function (record, response) {
                                                if (response.success) {
                                                    var response = Ext4.JSON.decode(response.response.responseText);
                                                    Ext4.getCmp('group-members-grid').getStore().load({
                                                        params: {
                                                            groupid: groupId,
                                                            activeOnly: activeOnly
                                                        }
                                                    });
                                                    if (response.failure != undefined) {
                                                        var messageText = "";
                                                        for (var property in response.failure) {
                                                            if (response.failure.hasOwnProperty(property)) {
                                                                messageText = messageText + "<br><strong>" + property + "</strong> : " + response.failure[property];
                                                            }

                                                        }
                                                        Ext4.Msg.alert("Failures", messageText);
                                                    }
                                                    else {
                                                        formPanel.getForm().reset();
                                                    }

                                                }
                                                else {

                                                    Ext4.MessageBox.alert('Something went wrong', response.error);
                                                }

                                            }
                                        });
                                    }
                                }
                            ]
                        }
                    ]
                }

            ]


        },
        {
            xtype: 'checkbox',
            fieldLabel: 'Active Only',
            padding: '5',
            checked: true,
            handler: function () {
                this.up('window').setActiveOnly(this.getValue());
                Ext4.getCmp('group-members-grid').getStore().load({
                    params: {
                        groupid: this.up('window').getGroup(),
                        activeOnly: this.getValue()
                    }
                });
            }
        },
        {
            xtype: 'panel',
            height: 500,
            items: [
                {
                    xtype: "members-grid-panel",
                    title: 'Animals',
                    height: 500
                }
            ]
        }
    ]
    ,
    setGroup: function (groupId) {
        this.groupId = groupId;
        return this;
    }
    ,
    getGroup: function () {
        return this.groupId || null;
    }
    ,
    setGroupName: function (groupName) {
        this.groupName = groupName;
        return this;
    }
    ,
    getGroupName: function () {
        return this.groupName || null;
    }
    ,

    setActiveOnly: function (activeOnly) {
        this.activeOnly = activeOnly;
    }
    ,
    getActiveOnly: function () {
        return this.activeOnly || false;
    }
    ,


    loadMembersStore: function () {
        Ext4.getCmp('group-members-grid').getStore().load({
            params: {
                groupid: this.getGroup(),
                activeOnly: this.getActiveOnly()
            }
        });

        this.setTitle('Assigning Animals to Group: ' + this.getGroupName());
    }
    ,
    initComponent: function () {
        this.setActiveOnly(true);
        this.callParent(arguments);
    }
})
;