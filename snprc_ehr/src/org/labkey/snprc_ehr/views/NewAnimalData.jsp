<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page import="org.labkey.api.util.HtmlString" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>

<%
    /**
    * Created by thawkins on 4/17/2020
    */
%>

<%!
    @Override
    public void addClientDependencies(ClientDependencies dependencies)
    {
        dependencies.add("clientapi/ext4");
    }
%>
<%
    HtmlString contextPath = getContextPath();
%>
<script src="<%= contextPath %>/LDK/Utils.js"></script>

<script src="<%= contextPath %>/snprc_ehr/lib/stores/PotentialSireStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/AcquisitionTypesStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/CurrentSpeciesLookupStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/AnimalsComboStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/YesNoStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/GenderStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/models/NewAnimalDataModel.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/stores/NewAnimalDataStore.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/panels/NewAnimalDataGridPanel.js"></script>
<script src="<%= contextPath %>/snprc_ehr/lib/panels/NewAnimalDataFormPanel.js"></script>
<%--<script src="<%= contextPath %>/LDK/Utils.js"></script>--%>
<%--<script src="<%= contextPath %>/LDK/Assert.js"></script>--%>

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
            title: "New Animal Data",
            height: 700,
            items: [

                {
                    xtype: 'new-animal-data-grid-panel',
                    region: 'center'
                },
                {
                    xtype: 'new-animal-data-form-panel',
                    region: 'east',
                    //disabled: true
                }

            ],

            renderTo: document.getElementById("app-js-container")

        });
    });
</script>