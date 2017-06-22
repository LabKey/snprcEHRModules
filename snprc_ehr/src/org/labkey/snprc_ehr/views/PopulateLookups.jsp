<%
    /*
     * Copyright (c) 2017 LabKey Corporation
     *
     * Licensed under the Apache License, Version 2.0 (the "License");
     * you may not use this file except in compliance with the License.
     * You may obtain a copy of the License at
     *
     *     http://www.apache.org/licenses/LICENSE-2.0
     *
     * Unless required by applicable law or agreed to in writing, software
     * distributed under the License is distributed on an "AS IS" BASIS,
     * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     * See the License for the specific language governing permissions and
     * limitations under the License.
     */
%>

<%
    String contextPath = request.getContextPath();
%>

<script src="<%= contextPath %>/snprc_ehr/lib/stores/LookupSetsStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/LookupSetValuesStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/panels/LookupSetValuesGridPanel.js"></script>

<script src="<%= contextPath %>/snprc_ehr/lib/windows/LookupSetWindow.js"></script>
<style>
    .trash-btn {
        background-image: url('<%=contextPath%>/snprc_ehr/lib/images/trash-bin.png');
        width: 16px;
        height: 16px;
        background-size: cover;
        margin: 0 2px;
    }

    .edit-btn {
        background-image: url('<%=contextPath%>/snprc_ehr/lib/images/edit.png');
        width: 16px;
        height: 16px;
        background-size: cover;
        margin: 0 2px;
    }

    .add-btn {
        background-image: url('<%=contextPath%>/snprc_ehr/lib/images/add-btn.png');
        width: 16px;
        height: 16px;
        background-size: cover;
        margin: 0 2px;
    }
</style>

<div id="app-js-container"></div>

<script>

    Ext4.onReady(function () {

        Ext4.tip.QuickTipManager.init();

        Ext4.create("Ext.panel.Panel", {

            height: 800,

            items: [
                {
                    xtype: 'panel',
                    layout: {
                        type: 'hbox'
                    },
                    items: [
                        {
                            xtype: 'combo',
                            store: Ext4.create('LookupSetsStore'),
                            valueField: 'value',
                            displayField: 'label',
                            width: 450,
                            id: 'lookupSetsCombo',
                            name: 'lookupSetName',
                            fieldLabel: 'Lookup Set',
                            queryMode: 'local',
                            editable: false,
                            forceSelection: true,
                            listeners: {
                                select: function () {
                                    var lookupSetValuesGridPanel = Ext4.getCmp("lookupSetValuesGridPanel");
                                    lookupSetValuesGridPanel.getStore().setLookupSetName(this.getValue());
                                    lookupSetValuesGridPanel.getStore().load({params: {lookupSetName: this.getValue()}});
                                }
                            },
                            padding: 5
                        },
                        {
                            xtype: 'button',
                            text: 'Edit',
                            margin: 5,
                            iconCls: 'edit-btn',
                            handler: function () {
                                //Edit selected lookup set
                                var lookupSetCombo = Ext4.getCmp("lookupSetsCombo");
                                var record = lookupSetCombo.findRecordByValue(lookupSetCombo.getValue());

                                var lookupSetWindow = Ext4.create("LookupSetWindow");
                                lookupSetWindow.down('form').getForm().setValues({
                                    'lookupSetName': record.get('value'),
                                    'lookupSetLabel': record.get('label')
                                });
                                lookupSetWindow.show();
                            }
                        },
                        {
                            xtype: 'button',
                            text: 'remove',
                            iconCls: 'trash-btn',
                            margin: 5,
                            handler: function () {
                                //Remove selected lookup set
                                var lookupSetCombo = Ext4.getCmp("lookupSetsCombo");
                                var set = lookupSetCombo.getValue();
                                if (set) {
                                    Ext4.Ajax.request({
                                        url: LABKEY.ActionURL.buildURL("RelatedTables", "DeleteLookupSet"),
                                        method: 'POST',
                                        params: {lookupSetName: set},
                                        success: function () {
                                            lookupSetCombo.getStore().load({
                                                callback: function () {
                                                    lookupSetCombo.fireEvent("select");
                                                }
                                            });
                                        },
                                        failure: function () {

                                            Ext4.Msg.alert("Error", "Unable to Delete Lookup Set")
                                        }
                                    });
                                }

                            }
                        },
                        {
                            xtype: 'button',
                            text: 'New',
                            margin: 5,
                            iconCls: 'add-btn',
                            handler: function () {
                                //Add lookup set
                                var lookupSetWindow = Ext4.create("LookupSetWindow");
                                lookupSetWindow.show();
                            }
                        }

                    ]


                },
                {
                    xtype: 'lookup-set-values-grid-panel',
                    id: 'lookupSetValuesGridPanel'
                }
            ],

            renderTo: document.getElementById("app-js-container")

        });
    });
</script>