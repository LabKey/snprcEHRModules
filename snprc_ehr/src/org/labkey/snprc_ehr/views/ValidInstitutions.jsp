<%
    /*
     * Copyright (c) 2016 LabKey Corporation
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
<script src="<%= contextPath %>/snprc_ehr/lib/models/InstitutionModel.js"></script>

<script src="<%= contextPath %>/snprc_ehr/lib/stores/InstitutionsStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/StatesStore.js"></script>


<script src="<%= contextPath %>/snprc_ehr/lib/panels/InstitutionsGridPanel.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/panels/InstitutionFormPanel.js"></script>


<script src="<%= contextPath %>/snprc_ehr/lib/windows/InstitutionWindow.js"></script>

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

    .link-btn {
        background-image: url('<%=contextPath%>/snprc_ehr/lib/images/link.png');
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

<%
    /**
     * Displays Valid Institutions' grid
     *
     */

%>

<div id="app-js-container"></div>
<script>

    Ext4.onReady(function () {
        Ext4.tip.QuickTipManager.init();


        Ext4.create("Ext.panel.Panel", {
            layout: 'border',
            title: "Institutions",
            height: 800,
            items: [

                {
                    xtype: 'institutions-grid-panel',
                    region: 'center'
                }

            ],

            renderTo: document.getElementById("app-js-container")

        });
    });
</script>