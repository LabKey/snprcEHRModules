/**
 * Created by lkacimi on 4/4/2017.
 */
Ext4.define("GroupMembersGridPanel", {
    extend: 'Ext.grid.Panel',
    alias: 'widget.members-grid-panel',
    id: 'group-members-grid',
    store: Ext4.create('GroupMembersStore'),
    height: 500,
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
            dataIndex: 'date'
        },
        {
            text: "End Date",
            dataIndex: "enddate"
        }, {
            header: 'Actions',
            xtype: 'actioncolumn',
            items: [

                {
                    tooltip: 'Delete',
                    handler: function (grid, rowIndex, colIndex, item, e, record) {
                        var grid = this.up('grid');
                        var window = this.up('window');
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

                    },
                    iconCls: "trash-btn"

                }
            ]
        }
    ]
});