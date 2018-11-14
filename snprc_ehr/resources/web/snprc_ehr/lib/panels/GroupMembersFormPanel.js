/*
 * Copyright (c) 2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by thawkins on 8/16/2018.
 */
Ext4.define('GroupMembersFormPanel', {
    extend: "Ext.form.Panel",
    alias: "widget.group-members-form-panel",
    id: 'group-members-form-panel',
    bodyStyle: 'padding:5px 5px 0',
    labelWidth: 300,
    defaults: {width: 445},
    store: Ext4.create('GroupMembersStore'),
    items: [
        {
            xtype: 'textfield',
            name: 'id',
            fieldLabel: 'Animal'
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
        },
        {
            xtype: 'textfield',
            name: 'groupid',
            fieldLabel: 'Group Id',
            hidden: true
        },
        {
            xtype: 'textfield',
            name: 'objectid',
            fieldLabel: 'Group Id',
            hidden: true
        }

     ]
    ,
    buttons: [
        {
            text: 'Save',
            handler: function () {
                var window = this.up('window');
                var form = this.up('form').getForm();

                if (!form.isValid()) {
                    return;
                };

                //console.log(form.getValues());


                var memberRecord = Ext4.create("GroupMemberModel", {
                    groupid: this.up('window').getGroup(),
                    id: form.getValues()['id'],
                    date: form.getValues()['date'],
                    enddate: form.getValues()['enddate'],
                    objectid: form.getValues()['objectid']
                });

                var groupId = this.up('window').getGroup();
                var activeOnly = this.up('window').getActiveOnly();
                var formPanel = this.up('form');

                memberRecord.save({
                    callback: function (record, response) {
                        //console.log(record);
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
                            Ext4.MessageBox.alert('Something went wrong', 'Unable to update the record');
                        }

                  }
                });





                //console.log('GroupMembersFormPanel - Submit clicked')

            }
        }
    ]

});
