<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
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
<%!
    @Override
    public void addClientDependencies(ClientDependencies dependencies)
    {

        dependencies.add("clientapi/ext3");
        dependencies.add("clientapi/ext4");
        dependencies.add("extWidgets/DetailsPanel.js");
        dependencies.add("vis/vis");
    }
%>
<%
    String contextPath = request.getContextPath();
%>

<script>

    Date.prototype.format = function (format) {
        if (Date.formatFunctions[format] == null) {
            Date.createFormat(format);
        }
        return Date.formatFunctions[format].call(this);
    };

</script>
<script src="<%= contextPath %>/LDK/Utils.js"></script>
<script src="<%= contextPath %>/LDK/Assert.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/AnimalsByLocationTreeStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/panels/AnimalsByLocationTreePanel.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/panels/AnimalsByLocationReportsContainer.js"></script>
<script src="<%= contextPath %>/LDK/panel/ContentResizingPanel.js"></script>
<script src="<%= contextPath %>/LDK/ConvertUtils.js"></script>
<script src="<%= contextPath %>/LDK/QueryHelper.js"></script>
<script src="<%= contextPath %>/LDK/SelectRowsRow.js"></script>
<script src="<%= contextPath %>/LDK/panel/QueryPanel.js"></script>
<script src="<%= contextPath %>/LDK/field/NumberField.js"></script>
<script src="<%= contextPath %>/LDK/panel/WebpartPanel.js"></script>
<script src="<%= contextPath %>/LDK/panel/GraphPanel.js"></script>
<script src="<%= contextPath %>/ehr/data/ClinicalHistoryStore.js"></script>
<script src="<%= contextPath %>/ehr/panel/ClinicalHistoryPanel.js"></script>
<script src="<%= contextPath %>/ehr/panel/SnapshotPanel.js"></script>
<script src="<%= contextPath %>/ehr/panel/SmallFormSnapshotPanel.js"></script>

<script src="<%= contextPath %>/ehr/panel/WeightSummaryPanel.js"></script>
<script src="<%= contextPath %>/ehr/panel/WeightGraphPanel.js"></script>
<script src="<%= contextPath %>/ehr/utils.js"></script>
<script src="<%= contextPath %>/ehr/DemographicsCache.js"></script>
<script src="<%= contextPath %>/ehr/panel/KinShipPanel.js"></script>
<script src="<%= contextPath %>/LDK/panel/DetailsPanel.js"></script>
<script src="<%= contextPath %>/LDK/panel/MultiRecordDetailsPanel.js"></script>
<script src="<%= contextPath %>/ehr/panel/BloodSummaryPanel.js"></script>
<script src="<%= contextPath %>/snprc_ehr/Panel/BloodSummaryPanel.js"></script>
<script src="<%= contextPath %>/snprc_ehr/DemographicsRecord.js"></script>


<style>
    .x4-grid-tree-node-expanded .x4-tree-icon-parent, .x4-tree-icon-parent {
        background-image: url('<%=contextPath%>/snprc_ehr/lib/images/cage.ico');
        width: 16px;
        height: 16px;
        background-size: cover;
        margin: 0 2px;
    }

    .x4-tree-icon.animal.female {
        background-image: url('<%=contextPath%>/snprc_ehr/lib/images/female.ico');
        width: 16px;
        height: 16px;
        background-size: cover;
        margin: 0 2px;
    }

    .x4-tree-icon.animal.male {
        background-image: url('<%=contextPath%>/snprc_ehr/lib/images/male.ico');
        width: 16px;
        height: 16px;
        background-size: cover;
        margin: 0 2px;
    }

    .x4-tree-icon.animal.unknown-sex {
        background-image: url('<%=contextPath%>/snprc_ehr/lib/images/unknown-sex.ico');
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
            layout: 'border',
            height: 800,
            items: [

                {
                    xtype: 'panel',
                    region: 'west',
                    width: '20%',
                    split: true,
                    collapsible: true,
                    items: [
                        {
                            xtype: 'form',
                            padding: 5,
                            layout: 'column',
                            items: [
                                {
                                    'xtype': 'textfield',
                                    name: 'participantid',
                                    fieldLabel: 'Animal ID',
                                    allowBlank: false,
                                    width: 280,
                                    listeners: {
                                        specialkey: function (f, event) {
                                            if (event.getKey() == event.ENTER) {
                                                if (this.up('form').isValid()) {
                                                    //create an AJAX request
                                                    Ext4.Ajax.request({
                                                        url: LABKEY.ActionURL.buildURL("AnimalsByLocation", "GetLocationsPath"),
                                                        method: 'POST',
                                                        params: {
                                                            'participantid': this.up('form').getValues()['participantid']
                                                        },
                                                        scope: this,
                                                        //method to call when the request is successful
                                                        success: this.up('form').onValidAnimal,
                                                        //method to call when the request is a failure
                                                        failure: this.up('form').onWrongAnimal
                                                    });
                                                }
                                            }
                                        }
                                    }
                                },
                                {
                                    xtype: 'button',
                                    text: "Submit",
                                    handler: function () {
                                        if (this.up('form').isValid()) {
                                            //create an AJAX request
                                            Ext4.Ajax.request({
                                                url: LABKEY.ActionURL.buildURL("AnimalsByLocation", "GetLocationsPath"),
                                                method: 'POST',
                                                params: {
                                                    'participantid': this.up('form').getValues()['participantid']
                                                },
                                                scope: this,
                                                //method to call when the request is successful
                                                success: this.up('form').onValidAnimal,
                                                //method to call when the request is a failure
                                                failure: this.up('form').onWrongAnimal
                                            });
                                        }
                                    }

                                }
                            ],
                            selectAnimal: function (animal) {
                                var treePanel = Ext4.getCmp('animals-by-location-tree-panel');
                                var record = treePanel.getStore().getNodeById(animal.toUpperCase());
                                treePanel.getSelectionModel().select(record);
                                treePanel.fireEvent("itemclick", treePanel, record);
                                treePanel.getView().scrollRowIntoView(record);
                            },

                            onValidAnimal: function (response) {
                                //Received response from the server
                                var path = Ext4.JSON.decode(response.responseText);
                                var pathArray = path.path;
                                var animalId = path.animal;
                                if (pathArray == undefined || pathArray.length == 0 || animalId == undefined || animalId == null) {
                                    Ext4.MessageBox.alert('Error loading Animal', 'Please make sure the animal ID is valid and try again');
                                    return;
                                }

                                var treePanel = Ext4.getCmp('animals-by-location-tree-panel');

                                var subPath = pathArray.shift();
                                var node = treePanel.getStore().getById(subPath.id.toUpperCase());
                                var thisForm = this.up('form');
                                if (node != undefined) {
                                    node.expand(false, function () {
                                        subPath = pathArray.shift();
                                        node = undefined;
                                        if (subPath && subPath.id) {
                                            node = treePanel.getStore().getById(subPath.id.toUpperCase());
                                        }
                                        if (node != undefined) {
                                            node.expand(false, function () {
                                                //select animal
                                                thisForm.selectAnimal(animalId);

                                            });
                                        }
                                        else {
                                            thisForm.selectAnimal(animalId);
                                        }
                                    });
                                }

                            },
                            onWrongAnimal: function () {
                                Ext4.MessageBox.alert('Error loading Animal', 'Please make sure the animal ID is valid and try again');
                            }
                        },
                        {
                            xtype: 'animals-by-location-tree-panel',
                            layout: 'fit',
                            id: 'animals-by-location-tree-panel'

                        }
                    ]

                },

                {
                    xtype: 'animals-by-location-reports-container',
                    id:'animals-by-location-ldk-grids-container',
                    region:'center'
                }
            ],

            renderTo: document.getElementById("app-js-container")

        });
    });
</script>