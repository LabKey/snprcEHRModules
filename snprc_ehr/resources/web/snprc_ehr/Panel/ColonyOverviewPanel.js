/*
 * Copyright (c) 2013-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('SNPRC_EHR.panel.ColonyOverviewPanel', {
    extend: 'EHR.panel.ColonyOverviewPanel',

    initComponent: function(){
        this.filterArray = [
            LABKEY.Filter.create('calculated_status', 'Alive', LABKEY.Filter.Types.EQUAL)
            //LABKEY.Filter.create('gender/meaning', 'Unknown', LABKEY.Filter.Types.NEQ)
        ];
        this.childFilterArray = [
            LABKEY.Filter.create('Id/demographics/calculated_status', 'Alive', LABKEY.Filter.Types.EQUAL),
            LABKEY.Filter.create('Id/demographics/gender/meaning', 'Unknown', LABKEY.Filter.Types.NEQ)
        ];

        Ext4.apply(this, {
            border: false,
            defaults: {
                border: false
            },
            items: [{
                html: 'This page is designed to give an overview of the colony',
                style: 'padding-bottom: 20px;'
            },{
                xtype: 'tabpanel',
                border: true,
                defaults: {
                    border: false,
                    listeners: {
                        scope: this,
                        activate: function(tab){
                            Ext4.History.add('tab=' + tab.itemId);
                        }
                    }
                },
                items: this.getTabs()
            }]
        });

        this.activeTab = 1;

        var tokens = document.location.hash.split('#');
        if (tokens && tokens.length > 1){
            tokens = tokens[1].split('&');
            for (var i=0;i<tokens.length;i++){
                var t = tokens[i].split('=');
                if (t.length == 2 && t[0] == 'tab'){
                    //this.activeTab = t[0];
                }
            }
        }

        this.callParent();
    }
});