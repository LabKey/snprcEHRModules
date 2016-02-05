

Ext4.define('SNPRC.panel.ColonyUsagePanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.snprc-colonyusagepanel',

    initComponent: function(){
        Ext4.apply(this, {
            minHeight: 400,
            border: false,
            style: 'padding: 5px;'
        });

        this.callParent();

        this.add(this.getAssignedTable());

        //this.loadData();
    },

    getAssignedTable: function(){
        return {
            xtype: 'ldk-querypanel',
            //title: 'Raw Data',
            style: 'margin: 5px;',
            queryConfig: {
                frame: 'none',
                containerPath: this.containerPath,
                schemaName: 'study',
                queryName: 'colonyUsage',
                filterArray: this.filterArray,
                failure: LDK.Utils.getErrorCallback()
            }
        }
    }
});