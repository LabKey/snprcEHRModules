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
<script src="<%= contextPath %>/LDK/panel/ContentResizingPanel.js"></script>
<script src="<%= contextPath %>/LDK/panel/QueryPanel.js"></script>

<script src="<%= contextPath %>/LDK/Utils.js"></script>
<div id="app-js-container"></div>
<script>

    Ext4.onReady(function () {

        Ext4.create("Ext.panel.Panel", {
            items: [
                {
                    xtype: 'ldk-querypanel',
                    style: 'margin-bottom: 10px;',
                    title: 'Valid Birth codes',
                    overflowY: 'auto',
                    queryConfig: LDK.Utils.getReadOnlyQWPConfig({
                        title: 'Valid codes',
                        schemaName: 'snprc_ehr',
                        queryName: 'valid_birth_code',
                        allowHeaderLock: false,
                        showInsertNewButton: true,
                        showUpdateColumn: true,
                        showDeleteButton:true
                    })

                }
            ],

            renderTo: document.getElementById("app-js-container")

        });

        Ext4.create("Ext.panel.Panel", {

            items: [
                {
                    xtype: 'ldk-querypanel',
                    style: 'margin-bottom: 10px; margin-top:50px;',
                    title: 'Valid Death codes',
                    overflowY: 'auto',
                    queryConfig: LDK.Utils.getReadOnlyQWPConfig({
                        title: 'Valid codes',
                        schemaName: 'snprc_ehr',
                        queryName: 'valid_death_code',
                        allowHeaderLock: false,
                        showInsertNewButton: true,
                        showUpdateColumn: true,
                        showDeleteButton:true
                    })

                }


            ],

            renderTo: document.getElementById("app-js-container")

        });


    });

</script>
