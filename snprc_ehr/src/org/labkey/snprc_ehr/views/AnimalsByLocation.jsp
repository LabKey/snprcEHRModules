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
<script src="<%= contextPath %>/snprc_ehr/lib/stores/AnimalsByLocationTreeStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/panels/AnimalsByLocationTreePanel.js"></script>
<script src="<%= contextPath %>/LDK/panel/ContentResizingPanel.js"></script>
<script src="<%= contextPath %>/LDK/panel/QueryPanel.js"></script>

<script src="<%= contextPath %>/LDK/Utils.js"></script>
<style>
    /*Overriding tree default icons is not a great idea, but it works*/
    .x4-tree-icon.x4-tree-icon-leaf {
        background-image: url('<%=contextPath%>/snprc_ehr/lib/images/monkey.png');
        width: 16px;
        height: 16px;
        background-size: cover;
        margin: 0 2px;
    }

    .x4-grid-tree-node-expanded .x4-tree-icon-parent, .x4-tree-icon-parent {
        background-image: url('<%=contextPath%>/snprc_ehr/lib/images/location.png');
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
                    xtype: 'animals-by-location-tree-panel',
                    region: 'west',
                    width: '20%',
                    split: true,
                    collapsible: true
                },
                {
                    xtype:'panel',
                    id:'animals-by-location-ldk-grids-container',
                    layout: {
                        type: 'accordion',
                        titleCollapse: true,
                        animate: true
                    },
                    items:[
                        {
                            xtype:'tabpanel',
                            title:'Assignment And Groups',
                            items:[

                            ]

                        },
                        {
                            xtype:'tabpanel',
                            title:'Behavior'

                        },
                        {
                            xtype:'tabpanel',
                            title:'Clinical',
                            items:[

                            ]

                        },
                        {
                            xtype:'tabpanel',
                            title:'Colony Management',
                            items:[

                            ]

                        },
                        {
                            xtype:'tabpanel',
                            title:'General',
                            items:[

                            ]

                        },
                        {
                            xtype:'tabpanel',
                            title:'Genetics',
                            items:[

                            ]

                        },
                        {
                            xtype:'tabpanel',
                            title:'Lab Results',
                            items:[

                            ]

                        },
                        {
                            xtype:'tabpanel',
                            title:'Pathology',
                            items:[

                            ]

                        },
                        {
                            xtype:'tabpanel',
                            title:'Reproductive Management',
                            items:[

                            ]


                        },
                        {
                            xtype:'tabpanel',
                            title:'Surgery',
                            items:[

                            ]

                        }
                    ],
                    region:'center'
                }
            ],

            renderTo: document.getElementById("app-js-container")

        });
    });
</script>