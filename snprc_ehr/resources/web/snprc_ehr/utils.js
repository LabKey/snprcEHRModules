SNPRC_EHR.Utils = new function () {
    return {

        editUIButtonHandler: function (schemaName, queryName, dataRegionName, paramMap, copyFilters) {
            var params = {
                schemaName: schemaName,
                'query.queryName': queryName
            };

            if (copyFilters !== false && dataRegionName) {
                var array = LABKEY.DataRegions[dataRegionName].getUserFilterArray();
                if (array && array.length) {
                    for (var i = 0; i < array.length; i++) {
                        var filter = array[i];
                        params[filter.getURLParameterName()] = filter.getURLParameterValue();
                    }
                }

                //append non-removeable filters
                if (LABKEY.DataRegions[dataRegionName].getBaseFilters().length) {
                    var array = LABKEY.DataRegions[dataRegionName].getBaseFilters();
                    for (var i = 0; i < array.length; i++) {
                        var filter = array[i];
                        params[filter.getURLParameterName()] = filter.getURLParameterValue();
                    }
                }
            }

            if (paramMap != null) {
                for (var param in paramMap) {
                    if (LABKEY.ActionURL.getParameter(param)) {
                        params[paramMap[param]] = LABKEY.ActionURL.getParameter(param);
                    }
                }
            }

            window.location = LABKEY.ActionURL.buildURL('snprc_ehr', 'updateQuery', null, params);
        },
        showFlagPopup: function (id, el) {
            var ctx = EHR.Utils.getEHRContext() || {};
            Ext4.create('Ext.window.Window', {
                title: 'Flag Details: ' + id,
                width: 880,
                modal: true,
                bodyStyle: 'padding: 5px;',
                items: [{
                    xtype: 'grid',
                    cls: 'ldk-grid', //variable row height
                    border: false,
                    store: {
                        type: 'labkey-store',
                        containerPath: ctx['EHRStudyContainer'],
                        schemaName: 'study',
                        queryName: 'flags',
                        columns: 'Id,date,enddate,flag/category,flag/value,remark,performedby',
                        filterArray: [LABKEY.Filter.create('Id', id), LABKEY.Filter.create('isActive', true),
                            LABKEY.Filter.create('QCState/PublicData', true)],
                        autoLoad: true
                    },
                    viewConfig: {},
                    columns: [{
                        header: 'Category',
                        dataIndex: 'flag/category'
                    }, {
                        header: 'Meaning',
                        dataIndex: 'flag/value',
                        tdCls: 'ldk-wrap-text',
                        width: 200
                    }, {
                        header: 'Date Added',
                        dataIndex: 'date',
                        xtype: 'datecolumn',
                        format: LABKEY.extDefaultDateFormat,
                        width: 110
                    }, {
                        header: 'Date Removed',
                        dataIndex: 'enddate',
                        xtype: 'datecolumn',
                        format: LABKEY.extDefaultDateFormat,
                        width: 110
                    }, {
                        header: 'Remark',
                        dataIndex: 'remark',
                        tdCls: 'ldk-wrap-text',
                        width: 210
                    }, {
                        header: 'Entered By',
                        dataIndex: 'performedby',
                        width: 110
                    }],
                    border: false
                }],
                buttons: [{
                    text: 'Close',
                    handler: function (btn) {
                        btn.up('window').close();
                    }
                }]
            }).show(el);
        },
        showMhcPopup: function (id, el) {
            var ctx = EHR.Utils.getEHRContext() || {};
            Ext4.create('Ext.window.Window', {
                title: 'MHC Details: ' + id,
                width: 880,
                modal: true,
                bodyStyle: 'padding: 5px;',
                items: [{
                    xtype: 'grid',
                    cls: 'ldk-grid', //variable row height
                    border: false,
                    store: {
                        type: 'labkey-store',
                        containerPath: ctx['EHRStudyContainer'],
                        schemaName: 'snprc_ehr',
                        queryName: 'mhcData',
                        columns: 'Id,Haplotype,MhcValue,DataFileSource,Modified',
                        filterArray: [LABKEY.Filter.create('Id', id)],
                        autoLoad: true
                    },
                    viewConfig: {},
                    columns: [{
                        header: 'Haplotype',
                        dataIndex: 'Haplotype',
                        tdCls: 'ldk-wrap-text',
                        width: 200
                    }, {
                        header: 'MHC Value',
                        dataIndex: 'MhcValue',
                        tdCls: 'ldk-wrap-text',
                        width: 200
                    }, {
                        header: 'Data File Source',
                        dataIndex: 'DataFileSource',
                        tdCls: 'ldk-wrap-text',
                        width: 210
                    }, {
                        header: 'Last Updated',
                        dataIndex: 'Modified',
                        xtype: 'datecolumn',
                        format: LABKEY.extDefaultDateFormat,
                        width: 110
                    }],
                    border: false
                }],
                buttons: [{
                    text: 'Close',
                    handler: function (btn) {
                        btn.up('window').close();
                    }
                }]
            }).show(el);
        }
    }
}




