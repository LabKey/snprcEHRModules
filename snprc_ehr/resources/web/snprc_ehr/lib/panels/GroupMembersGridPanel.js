/*
 * Copyright (c) 2017-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/**
 * Created by lkacimi on 4/4/2017.
 *

 *
 *
 */
Ext4.define("GroupMembersGridPanel", {
    extend: 'Ext.grid.Panel',
    alias: 'widget.members-grid-panel',
    id: 'group-members-grid',
    store: Ext4.create('GroupMembersStore'),
    scope: this,
    listeners: {

        edit: function (src, e) {
            var record = e.record;
            if (record.dirty) {
                this.updateGroupMember();
            }
        }
    },
    height: 500,
    setType: 'cellmodel',
    plugins: [
        {
            ptype: 'rowediting',
            clicksToEdit: 2
        }
    ],
    columns: [
        {
            text: 'Group',
            dataIndex: 'groupid',
            hidden: true,
            hideable: false
        },
        {
            text: 'Animal',
            dataIndex: 'id'
        },
        {
            text: "Start Date",
            dataIndex: 'date',
            type: 'date',
            renderer: Ext.util.Format.dateRenderer('m/d/Y'),
            editor: {
                xtype: 'datefield'
            },
            change: function () {

            }
        },

        {
            text: "End Date",
            dataIndex: "enddate",
            type: 'date',
            renderer: Ext.util.Format.dateRenderer('m/d/Y'),
            editor: {
                xtype: 'datefield'
            }
        },
        {
            text: 'Objectif',
            dataIndex: 'objectid',
            hidden: true,
            hideable: false
        },
        {
            header: 'Actions',
            xtype: 'actioncolumn',
            items: [

                {
                    tooltip: 'Delete',
                    handler: function (grid, rowIndex, colIndex, item, e, record) {
                        Ext4.MessageBox.confirm('Confirm', 'Are you sure you want to delete this animal?',
                            function (btn) {
                                if (btn === 'yes') {
                                    var window = grid.up('window');
                                    grid.getStore().removeAt(rowIndex);
                                    grid.getStore().sync({
                                        failure: function () {
                                            grid.getStore().load({
                                                params: {
                                                    'groupid': window.getGroup(),
                                                    'activeOnly': window.getActiveOnly()
                                                }
                                            });
                                            Ext4.Msg.alert('Error', 'Unable to delete this Member');
                                        },
                                    });

                                }
                            }
                        )
                    },
                    iconCls: "trash-btn"

                }
            ]
        }
    ]
    ,
    buttons: [
        {
            text: 'close',
            handler: function () {
                this.up('window').close();
            }
        }
    ],
    updateGroupMember: function () {

        this.getStore().save({
            scope: this,
            success: function (batch) {
                var success = batch.operations[0].request.scope.reader.jsonData["success"];
                if (success) {
                    console.log('Successfully updated animal group membership');
                }
                else {
                    var failureMsg = batch.operations[0].request.scope.reader.jsonData["message"];
                    Ext4.Msg.alert('Update failed',  failureMsg);
                }
            },
            failure: function (batch) {
                var failureMsg = batch.operations[0].request.scope.reader.jsonData["message"];
                Ext4.Msg.alert('Update failed', failureMsg);
            }
        });
    }

});





