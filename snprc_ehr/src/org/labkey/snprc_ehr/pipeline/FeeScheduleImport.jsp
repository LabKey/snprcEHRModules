<%@ page import="org.labkey.api.data.Container" %>
<%@ page import="org.labkey.api.security.permissions.AdminPermission" %>
<%@ page import="org.labkey.api.view.HttpView" %>
<%@ page import="org.labkey.api.view.JspView" %>
<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page import="org.labkey.snprc_ehr.controllers.FeeScheduleController" %>
<%@ page import="org.labkey.snprc_ehr.controllers.FeeScheduleController.FeeScheduleImportForm" %>
<%@ taglib prefix="labkey" uri="http://www.labkey.org/taglib" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%!
    @Override
    public void addClientDependencies(ClientDependencies dependencies)
    {
        dependencies.add("clientapi/ext4");
    }
%>
<%
    JspView<FeeScheduleImportForm> me = (JspView<FeeScheduleImportForm>) HttpView.currentView();
    FeeScheduleImportForm bean = me.getModelBean();

    Container c = getViewContext().getContainerNoTab();
    Container project = c.getProject();
    boolean isProjectAdmin = project != null && project.hasPermission(getUser(), AdminPermission.class);
    String importFormId = "pipelineImportForm";

%>

<labkey:errors/>
<labkey:form id="<%=h(importFormId)%>"
             action="<%=h(buildURL(FeeScheduleController.FeeScheduleImportAction.class))%>" method="post">
    <input type="hidden" name="filePath" value=<%=q(bean.getFilePath())%>>

    <table class="labkey-data-region-legacy labkey-show-borders">
        <tbody>
        <tr>
            <th>File</th>
            <th>Size</th>
            <th>Modified</th>
        </tr>

        <tr class="labkey-alternate-row">
            <td><%=h(bean.getName())%>
            </td>
            <td align="right"><%=h(bean.getSize())%>
            </td>
            <td><%=h(bean.getDate())%>
            </td>

        </tr>

        </tbody>
    </table>
    <div id="startPipelineImportForm"></div>
</labkey:form>

<div id="app-js-container"/>

<style>
    .import-btn {
        margin-top: 30px;

    }
</style>
<script type="text/javascript">
    Ext4.onReady(function () {

        Ext4.create('Ext4.button.Button', {
            text: 'Start Import',
            scope: this,
            cls: 'import-btn',
            handler: function () {
                var confirmMsgs = [];
                //confirmMsgs.push("Fee Schedule File name: ");
                confirmMsgs.push(<%=q(bean.getName())%>);

                confirmMsgs.push("<br/>Import this Fee Schedule?");
                Ext4.Msg.confirm("Confirmation", confirmMsgs.join('<br/>'), function (btnId) {
                    if (btnId == 'yes')
                        document.getElementById('pipelineImportForm').submit();
                });

            },
            renderTo: document.getElementById("app-js-container")
        })
    });
</script>
