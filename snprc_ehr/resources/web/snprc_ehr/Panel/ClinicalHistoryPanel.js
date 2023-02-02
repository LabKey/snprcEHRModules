/**
 * @cfg subjectId
 * @cfg minDate
 * @cfg maxDate
 * @cfg maxGridHeight
 * @cfg autoLoadRecords
 * @cfg hideExportBtn
 * @cfg sortMode
 * @cfg checkedItems
 * @cfg showMaxDate
 * @cfg redacted
 * @cfg printMode
 */
Ext4.define('SNPRC.panel.ClinicalHistoryPanel', {
    extend: 'EHR.panel.ClinicalHistoryPanel',
    alias: 'widget.snprc-clinicalhistorypanel',

    getGridConfig: function(){
        return {
            xtype: 'grid',
            border: this.printMode ? false : true,
            minHeight: 100,
            minWidth: this.width - 50,
            cls: 'ldk-grid',
            maxHeight: this.maxGridHeight,
            height: this.gridHeight,
            hideHeaders: true,
            deferEmptyText: true,
            viewConfig : {
                emptyText: 'There are no records to display',
                deferEmptyText: true,
                enableTextSelection: true,
                border: false,
                stripeRows : true
            },
            columns: this.getColumnConfig(),
            features: [this.getGroupingFeature()],
            store: this.getStoreConfig(),
            itemId: 'gridPanel',
            width: this.width,
            subjectId: this.subjectId,
            caseId: this.caseId,
            minDate: this.minDate,
            maxDate: this.maxDate,
            tbar: this.hideGridButtons ? null : {
                border: true,
                items: [{
                    xtype: 'datefield',
                    fieldLabel: 'Min Date',
                    itemId: 'minDate',
                    labelWidth: 80,
                    width: 200,
                    value: this.minDate
                },{
                    xtype: 'datefield',
                    fieldLabel: 'Max Date',
                    itemId: 'maxDate',
                    labelWidth: 80,
                    width: 200,
                    hidden: this.showMaxDate,
                    value: this.maxDate
                },{
                    xtype: 'button',
                    text: 'Reload',
                    handler: function(btn){
                        var panel = btn.up('snprc-clinicalhistorypanel');
                        panel.doReload();
                    }

                },{
                    xtype: 'button',
                    text: 'Previous Day',
                    handler: function(btn){
                        var panel = btn.up('snprc-clinicalhistorypanel');
                        var yesterday = Ext4.Date.add(new Date(), Ext4.Date.DAY, -1)
                        panel.doBetweenDates(yesterday, yesterday);
                    }

                },{
                    xtype: 'button',
                    text: 'Last 30 Days',
                    handler: function(btn){
                        var panel = btn.up('snprc-clinicalhistorypanel');
                        var minDate = Ext4.Date.add(new Date(), Ext4.Date.DAY, -30)
                        panel.doBetweenDates(minDate, null);
                    }

                }, {
                    text: 'Show/Hide Types',
                    scope: this,
                    handler: function(btn){
                        this.showFilterPanel();
                    }
                },{
                    text: 'Collapse All',
                    hidden: this.printMode,
                    collapsed: false,
                    handler: function(btn){
                        var grid = btn.up('grid');
                        var feature = grid.getView().getFeature('historyGrouping');

                        if (btn.collapsed){
                            feature.expandAll();
                            btn.setText('Collapse All');
                        }
                        else {
                            feature.collapseAll();
                            btn.setText('Expand All')
                        }

                        btn.collapsed = !btn.collapsed;
                    }
                },{
                    hidden: this.printMode,
                    text: (this.sortMode == 'type' ? 'Group By Date' : 'Group By Type'),
                    sortMode: this.sortMode == 'type' ? 'date' : 'type',
                    scope: this,
                    handler: function(btn){
                        //toggle the button
                        if (btn.sortMode == 'type'){
                            btn.setText('Group By Date');
                            btn.sortMode = 'date';
                            this.changeMode('type');
                        }
                        else {
                            btn.setText('Group By Type');
                            btn.sortMode = 'type';
                            this.changeMode('date');
                        }
                    }
                },{
                    text: 'Print Version',
                    hidden: this.hideExportBtn || this.printMode,
                    scope: this,
                    handler: function(btn){
                        var params = {
                            hideGridButtons: true
                        };
                        if (this.subjectId)
                            params.subjectId = [this.subjectId];
                        if (this.caseId)
                            params.caseId = this.caseId;
                        if (this.minDate)
                            params.minDate = Ext4.util.Format.date(this.minDate, LABKEY.extDefaultDateFormat);
                        if (this.maxDate)
                            params.maxDate = Ext4.util.Format.date(this.maxDate, LABKEY.extDefaultDateFormat);
                        if (this.sortMode)
                            params.sortMode = this.sortMode;
                        if (this.checkedItems && this.checkedItems.length)
                            params.checkedItems = this.checkedItems.join(';');

                        var url = LABKEY.ActionURL.buildURL('snprc_ehr', 'clinicalHistoryExport', null, params);
                        window.open(url, '_blank');
                    }
                }]
            }
        };
    },

    doBetweenDates: function(minDate, maxDate){
        var minDateField = this.down('#minDate');
        var maxDateField = this.down('#maxDate');
        minDateField.setValue(minDate);
        maxDateField.setValue(maxDate);
        this.minDate = minDateField.getValue();
        this.maxDate = maxDateField.getValue();
        this.reloadData({
            minDate: this.minDate,
            maxDate: this.maxDate
        })
    },

    getColumnConfig: function(){
        return [{
            text: 'Category',
            dataIndex: 'category',
            tdCls: 'ldk-wrap-text',
            width: 90,
            renderer: function(value, cellMetaData, record, rowIndex, colIndex, store){
                if (record.get('categoryColor')){
                    cellMetaData.style = cellMetaData.style ? cellMetaData.style + ';' : '';
                    cellMetaData.style += 'background-color: ' + record.get('categoryColor') + ';';
                }

                return value;
            }
        },{
            text: 'Date',
            xtype: 'datecolumn',
            dataIndex: 'date',
            format: LABKEY.extDefaultDateTimeFormat,
            hidden: (this.sortMode == 'date'),
            width: 180
        },{
            text: '',
            dataIndex: 'timeString',
            hidden: (this.sortMode != 'date'),
            width: 80
        },{
            text: 'Description',
            dataIndex: 'html',
            minWidth: 300,
            tdCls: 'ldk-wrap-text',
            flex: 10
        }];
    },

});