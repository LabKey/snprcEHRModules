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
<%@ page import="org.labkey.snprc_ehr.SNPRC_EHRController" %>
<%@ taglib prefix="labkey" uri="http://www.labkey.org/taglib" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%
    SNPRC_EHRController.SSRSConfigForm form = (SNPRC_EHRController.SSRSConfigForm)getModelBean();
%>
<labkey:errors/>

<labkey:form method="post">
    <table>
        <tr>
            <td class="labkey-form-label"><label for="userInput">User name<%=helpPopup("User name", "Of the form \"DOMAIN\\USERNAME\"")%></label></td>
            <td><input size="30" id="userInput" name="user" value="<%= h(form.getUser())%>"/></td>
        </tr>
        <tr>
            <td class="labkey-form-label"><label for="passwordInput">Password</label></td>
            <td><input size="30" id="passwordInput" type="password" name="password" value="<%= h(form.getPassword())%>" /></td>
        </tr>
        <tr>
            <td class="labkey-form-label"><label for="baseURLInput">Base URL<%=helpPopup("Base URL", "Of the form \"https://HOSTNAME/ReportServer/Pages/ReportViewer.aspx\" - do not include report name, format, etc")%></label></td>
            <td><input size="80" id="baseURLInput" name="baseURL" value="<%= h(form.getBaseURL())%>" /></td>
        </tr>
        <tr>
            <td/>
            <td><%= button("Save").submit(true) %> <%= generateBackButton("Cancel") %></td>
        </tr>
    </table>
</labkey:form>