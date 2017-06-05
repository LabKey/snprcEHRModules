<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%@ taglib prefix="labkey" uri="http://www.labkey.org/taglib" %>
<%@ page import="org.labkey.snprc_ehr.controllers.RelatedTablesController" %>
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
<%
    /**
     * Displays an unordered list of related tables, each one is a link to a separate view
     *
     */

%>

<ul class="list">
    <li><a href="<%=h(buildURL(RelatedTablesController.GetValidInstitutionsViewAction.class))%>">Valid Institutions</a>
    </li>
    <li><a href="<%=h(buildURL(RelatedTablesController.GetValidVetsAction.class))%>">Valid Vets</a></li>
    <li><a href="<%=h(buildURL(RelatedTablesController.GetValidBirthDeathCodesViewAction.class))%>">Valid Birth / Death Codes</a></li>
    <li><a href="<%=h(buildURL(RelatedTablesController.GetPopulateLookupsViewAction.class))%>">Populate Lookups</a></li>

</ul>