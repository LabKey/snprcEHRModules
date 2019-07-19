<%
/*
 * Copyright (c) 2017-2019 LabKey Corporation
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
<%@ page import="org.labkey.api.view.HttpView" %>
<%@ page import="org.labkey.api.view.JspView" %>
<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page import="org.labkey.snprc_ehr.controllers.FeeScheduleController" %>
<%@ page import="org.labkey.snprc_ehr.pipeline.FeeScheduleImportForm" %>
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
    String importFormId = "FeeScheduleImportForm";
%>

<labkey:errors/>
<labkey:form id="<%=importFormId%>"
             action="<%= h(buildURL(FeeScheduleController.FeeScheduleImportAction.class)) %>" method="post">


    <div class="content">
        <input type="hidden" name="filePath" value=<%= q(bean.getFilePath()) %>>
        <input type="hidden" name="name" value=<%= q(bean.getName()) %>>
        <input type="hidden" name="date" value=<%= q(bean.getDate()) %>>
        <input type="hidden" name="tabPage"  id="tabPage" value=<%= q(bean.getTabPage()) %>>


        <table class="labkey-data-region-legacy labkey-show-borders">
            <tbody>
                <tr>
                    <%--<th>File Path</th>--%>
                    <th>File</th>
                    <th>Size</th>
                    <th>Modified</th>
                </tr>

                <tr class="labkey-alternate-row file-info">

                    <%--<td><%= h(bean.getFilePath()) %>--%>
                    <td><%= h(bean.getName()) %>
                    </td>
                    <td align="right"><%= h(bean.getSize()) %>
                    </td>
                    <td><%= h(bean.getDate()) %>
                    </td>

                </tr>
            </tbody>
        </table>

        <br>
        <h3>Tab Pages</h3>
        <table class="tab-page-table" width="20%">
            <tbody>
            <%

            int i = 1;
            String rowId;
            for (String name : bean.getAvailableTabPages())
            {
                if (name != null)
                {
                    rowId = "row-" + i;
            %>
            <tr>
                <td class="labkey-alternate-row tab-page-table-row" colspan="3" id=<%=h(rowId)%> >
                    <input type="radio" id="radio-1" name="radio-1" value=<%=q(name)%> > <%=h(name)%>
                </td>
            </tr>
            <%
                }
            } %>
            </tbody>
        </table>
        <br>

        <div class="selected-tab-pg" >


        </div>


    </div>
    <div class="error-box">
        <div class="error-text hide-error" >
            You must select a Tab Page before starting the import.
        </div>
    </div>

    <div class="choices">
        <h2>Choose the tab page you want to import.<br>Remember: Not all tab pages contain fee schedule data.</h2>
        <button type="button" class="btn" id="submit-btn">Start Import</button>

    </div>


</labkey:form>


<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

    /* ----- BUTTONS ----- */
.btn,
.btn:active,
.btn:focus
 {
    display: inline-block;
    padding: 5px 15px;
    font-weight: 300;
    text-decoration: none;
    border-radius: 20px !important;
    color: #fff !important;
    background-color: #116596 !important;
    border: #116596;
    outline: none;
    margin-right: 15px;
    transition: background-color 0.1s, border 0.1s, color 0.1s, font-weight 0.1s;
}


.btn:hover
{
    background-color: #ffffff !important;
    color: #116596 !important;
    border: 1px solid #116596;
    font-weight: 800;
    outline: none;
}

.error-border {
    border: 2px solid #ea3a4f !important;

}

.content {
    position: relative;
    width: 1140px;
    top: 2%;
    left: 5%;
}

.file-info {

}

.error-box {
    position: relative;
    /*background-color: #fff;*/
    /*border-radius: 5px;*/
    height: 30px;
    width: 90%;
    margin-left: 3%;
}
.error-text {
    position: relative;
    width: 1140px;
    color: #ea3a4f;
    font-size: 150%;
}
.hide-error {
    display: none;
}

</style>


<script type="text/javascript">
    var tabLabel;
    document.querySelector('.tab-page-table').addEventListener('click', function () {
        var selector;

        selector = document.querySelector('input[name="radio-1"]:checked');
        if (selector) {
            tabLabel = document.querySelector('input[name="radio-1"]:checked').value;
            document.getElementById('tabPage').value = tabLabel;

            // clear errors from UI
            document.querySelector('.tab-page-table').classList.remove('error-border');
            document.querySelector('.error-text').classList.add('hide-error');
        }
    });

    document.getElementById('submit-btn').addEventListener('click', function () {
        buttonHandler();
    });

    document.addEventListener('keypress', function (event) {
        if (event.keyCode === 13 || event.which === 13) {
            buttonHandler();
        }
    });

    var buttonHandler = function () {

        // validate form
        var selector = document.querySelector('input[name="radio-1"]:checked');

        if (selector) {
            // do something

        } else {
            // display error if a selection hasn't been made
            document.querySelector('.error-text').classList.remove('hide-error');
            document.querySelector('.tab-page-table').classList.add('error-border');
            document.getElementById('row-1').focus();
            return false;
        }

        // confirm that user wants to import
        var confirmMsgs = [];

        confirmMsgs.push("<strong> File: </strong>" + <%= q(bean.getName()) %>);
        confirmMsgs.push("<strong> Tab Page: </strong>" + tabLabel);
        confirmMsgs.push("<br/>Import this Fee Schedule?");

        Ext4.Msg.confirm("Confirmation", confirmMsgs.join('<br/>'), function (id) {
            if (id === 'yes') {

                // submit the form
                document.getElementById('FeeScheduleImportForm').submit();
            }
            else {
                // clear error messages and stay on page

                document.querySelector('.error-text').classList.add('hide-error');
                document.querySelector('.tab-page-table').classList.remove('error-border');
                document.getElementById('row-1').focus();
            }
        });
    };

</script>