<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>

<%
    /*
     * Copyright (c) 2017-2018 LabKey Corporation
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
    }
%>
<%
    String contextPath = request.getContextPath();
%>
<script src="<%= contextPath %>/snprc_ehr/lib/models/GroupCategoryModel.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/models/GroupMemberModel.js"></script>

<script src="<%= contextPath %>/snprc_ehr/lib/stores/GroupCategoriesStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/SpeciesStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/AnimalGroupsStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/AnimalsComboStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/YesNoStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/GenderStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/GroupMembersStore.js"></script>

<script src="<%= contextPath %>/snprc_ehr/lib/panels/GroupCategoriesGridPanel.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/panels/GroupCategoryFormPanel.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/panels/GroupMembersGridPanel.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/panels/GroupsGridPanel.js"></script>

<script src="<%= contextPath %>/snprc_ehr/lib/windows/AssignAnimalsToGroupWindow.js"></script>
<style>
    .trash-btn {
        background-image: url('<%=contextPath%>/snprc_ehr/lib/images/trash-bin.png');
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

    .reset-btn {
        background-image: url('<%=contextPath%>/snprc_ehr/lib/images/reset-btn.png');
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
            title: "Animal Group Categories",
            height: 700,
            items: [

                {
                    xtype: 'group-categories-grid-panel',
                    region: 'center'
                },
                {
                    xtype: 'group-category-form-panel',
                    region: 'east'
                },
                {
                    xtype: 'groups-grid-panel',
                    title: 'Animal Groups',
                    region: 'south',
                    height: 350
                }

            ],

            renderTo: document.getElementById("app-js-container")

        });
    });
</script>