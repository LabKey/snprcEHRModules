/*
 * Copyright (c) 2012-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('EHR.reports');

//this contains SNPRC-specific reports that should be loaded on the animal history page
//this file is registered with EHRService, and should auto-load whenever EHR's
//dependencies are requested, provided this module is enabled

EHR.reports.kinshipSummary = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();
    var ids = panel.getFilterContext().subjects;

    tab.add({
        xtype: 'panel',
        border: false,
        subjectList: ids,
        bodyStyle: 'padding: 5px;',
        defaults: {
            border: false
        },
        items: [{
            xtype: 'ldk-linkbutton',
            hidden: !ids || !ids.length,
            text: 'Click Here To Limit To Animals In Selection',
            linkTarget: '_blank',
            linkCls: 'labkey-text-link',
            style: 'margin-bottom: 20px;',
            handler: function(btn){
                var p = btn.up('panel');
                if (p.subjectList) {
                    var qwp = p.down('ldk-querypanel').qwp;
                    if (qwp) {
                        qwp.removeableFilters = qwp.removeableFilters || [];
                        qwp.removeableFilters.push(LABKEY.Filter.create('Id2', p.subjectList.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF));

                        var dr = LABKEY.DataRegions[qwp.dataRegionName];
                        if (dr){
                            dr.addFilter(LABKEY.Filter.create('Id2', p.subjectList.join(';'), LABKEY.Filter.Types.EQUALS_ONE_OF));
                            dr.refresh();
                        }
                    }
                }
            }
        },{
            xtype: 'container',
            border: false,
            items: [{
                xtype: 'ldk-querypanel',
                style: 'margin-bottom:20px;',
                queryConfig: panel.getQWPConfig({
                    schemaName: 'ehr',
                    queryName: 'kinshipSummary',
                    title: 'Kinship' + title,
                    filters: filterArray.nonRemovable,
                    removeableFilters: filterArray.removable || []
                })
            }]
        }]
    });

}