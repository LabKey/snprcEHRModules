<%
/*
 * Copyright (c) 2019 LabKey Corporation
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

<%@ taglib prefix="labkey" uri="http://www.labkey.org/taglib" %>
<%@ page import="org.labkey.api.data.Container" %>
<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>

<%
    String contextPath = request.getContextPath();
    Container c = getContainer();
    String containerPath = c.getPath();
%>
<%!
    @Override
    public void addClientDependencies(ClientDependencies dependencies)
    {
        dependencies.add("clientapi/ext4");
    }
%>


<div id="ehr-lookuptables"></div>

<script type="text/javascript">

    section = document.getElementById("ehr-lookuptables");

    Ext4.onReady(function (){

        EHR.Security.init({
            success: onSuccess,
            scope: this
        });


        Ext4.get(section).update(
                '<div style="max-width:1000px">' +
                '<table>' +
                '<tr style="vertical-align:top">' +
                '    <td style="width:330px">' +
                '        <div id="menu1_'+section.id+'"></div>' +
                '    </td>' +
                '    <td style="width:330px;vertical-align:top">' +
                '        <div id="menu2_'+section.id+'"></div>' +
                '    </td>' +
                '    <td style="width:340px">' +
                '        <div id="menu3_'+section.id+'"></div>' +
                '    </td>' +
                '</tr>' +
                '</table>'
        );

        function onSuccess(data){
            var menuCfg1 = {
                renderTo: "menu1_"+section.id,
                sections: new Array(),
                colWidth: 330,
                renderer: function(item){
                    var cfg = {
                        html: '<a href="<%=contextPath%>/ehr<%=containerPath%>/updateTable.view?schemaName='+item.schemaName+'&query.queryName='+item.queryName+'">'+item.title+'</a>',
                        style: 'padding-left:5px;padding-bottom:8px'
                    };

                    return cfg;
                }
            }

            menuCfg1.sections = [{
                header: 'Housing',
                items: [
                    {queryName: 'areas', schemaName: 'ehr_lookups', title: 'Areas'},
                    {queryName: 'housingStatus', schemaName: 'ehr_lookups', title: 'Housing Status'},
                    {queryName: 'rooms', schemaName: 'ehr_lookups', title: 'Rooms (Valid Locations)'}
                ]
            },{
                header: 'Treatment Lists',
                items: [
                    {queryName: 'amount_units', schemaName: 'ehr_lookups', title: 'Drug Amount Units'},
                    {queryName: 'drug_categories', schemaName: 'ehr_lookups', title: 'Drug Categories'},
                    {queryName: 'conc_units', schemaName: 'ehr_lookups', title: 'Drug Concentration Units'},
                    {queryName: 'dosage_units', schemaName: 'ehr_lookups', title: 'Drug Dosage Units'},
                    {queryName: 'ValidDSGroup', schemaName: 'ehr_lookups', title: 'Diagnosis Groups'},
                    {queryName: 'ValidDXList', schemaName: 'ehr_lookups', title: 'Diagnosis Lists'},
                    {queryName: 'volume_units', schemaName: 'ehr_lookups', title: 'Drug Volume Units'},
                    //{queryName: 'drug_defaults', schemaName: 'ehr_lookups', title: 'Drug Default Values'},
                    {queryName: 'routes', schemaName: 'ehr_lookups', title: 'Drug Routes'},
                    {queryName: 'treatment_codes', schemaName: 'ehr_lookups', title: 'Common Treatments (Not used)'},
                    {queryName: 'treatment_frequency', schemaName: 'ehr_lookups', title: 'Treatment Frequencies'},

                ]
            },{
                header: 'Clinical/Anatomical Pathology Lists',
                items: [
                    {queryName: 'labwork_services', schemaName: 'snprc_ehr', title: 'Labwork Services'},
                    {queryName: 'labwork_panels', schemaName: 'snprc_ehr', title: 'Labwork Panel Test Ids'},
                    {queryName: 'labwork_types', schemaName: 'snprc_ehr', title: 'Labwork Types'},
                    {queryName: 'labworkChargeType', schemaName: 'ehr_lookups', title: 'Labwork Charge Types'},
                    {queryName: 'apath_record_status', schemaName: 'ehr_lookups', title: 'APath Record Status'},
                    {queryName: 'apath_death_type', schemaName: 'ehr_lookups', title: 'APath Death Types'},
                    {queryName: 'AccessionCode', schemaName: 'ehr_lookups', title: 'APath Accession Types'}

                ]
            }];


            var menuCfg2 = {
                renderTo: "menu2_"+section.id,
                sections: new Array(),
                colWidth: 330,
                renderer: function(item){
                    var cfg = {
                        html: '<a href="<%=contextPath%>/ehr<%=containerPath%>/updateTable.view?schemaName='+item.schemaName+'&query.queryName='+item.queryName+'">'+item.title+'</a>',
                        style: 'padding-left:5px;padding-bottom:8px'
                    };

                    return cfg;
                }
            }

            menuCfg2.sections = [{
                header: 'Drop-down Lists',
                items: [
                    {queryName: 'activeInactive', schemaName: 'ehr_lookups', title: 'Active/Inactive Status'},
                    {queryName: 'alopecia_score', schemaName: 'ehr_lookups', title: 'Alopecia Score'},
                    {queryName: 'id_type', schemaName: 'ehr_lookups', title: 'Animal ID Types'},
                    {queryName: 'status_codes', schemaName: 'ehr_lookups', title: 'Animal Status Codes'},
                    {queryName: 'flag_categories', schemaName: 'ehr_lookups', title: 'Animal Attribute (Flag) Categories'},
                    {queryName: 'flag_values', schemaName: 'ehr_lookups', title: 'Animal Attribute (Flag) values'},
                    {queryName: 'source', schemaName: 'ehr_lookups', title: 'Animal Source Codes'},
                    {queryName: 'AcquisitionType', schemaName: 'ehr_lookups', title: 'Acquisition Codes'},
                    {queryName: 'blood_sample_type', schemaName: 'ehr_lookups', title: 'Blood Sample Types (Not used)'},
                    {queryName: 'valid_bd_status', schemaName: 'snprc_ehr', title: 'Birth Date Status Codes'},
                    {queryName: 'valid_clinical_resolutions', schemaName: 'ehr_lookups', title: 'Clinical Resolution Types'},
                    {queryName: 'DispositionType', schemaName: 'ehr_lookups', title: 'Disposition Codes'},
                    {queryName: 'encounter_types', schemaName: 'ehr_lookups', title: 'Encounter Types'},
                    {queryName: 'geographic_origins', schemaName: 'ehr_lookups', title: 'Geographic Origins (Not used)'},
                    {queryName: 'ValidInstitutions', schemaName: 'snprc_ehr', title: 'Institution List'},
                    {queryName: 'preg_term_code', schemaName: 'ehr_lookups', title: 'Pregnancy Termination Codes'},
                    {queryName: 'proc_type', schemaName: 'ehr_lookups', title: 'Procedure Types'},
                    {queryName: 'rearing_type', schemaName: 'ehr_lookups', title: 'Rearing Types'},
                    {queryName: 'project_type', schemaName: 'ehr_lookups', title: 'SND Project Types'},
                    {queryName: 'tb_site', schemaName: 'ehr_lookups', title: 'TB Sites'},
                    {queryName: 'usda_levels', schemaName: 'ehr_lookups', title: 'USDA Levels'},
                    {queryName: 'ValidVets', schemaName: 'snprc_ehr', title: 'Veterinarian List'}
                ]
            }];

            var menuCfg3 = {
                renderTo: "menu3_"+section.id,
                sections: new Array(),
                colWidth: 340,
                renderer: function(item){
                    var cfg = {
                        html: '<a href="<%=contextPath%>/ehr<%=containerPath%>/updateTable.view?schemaName='+item.schemaName+'&query.queryName='+item.queryName+'">'+item.title+'</a>',
                        style: 'padding-left:5px;padding-bottom:8px'
                    };

                    return cfg;
                }
            }

            menuCfg3.sections = [{
                header: 'Other Lists',
                items: [
                    // {queryName: 'snomed', schemaName: 'ehr_lookups', title: 'SNOMED Codes'},
                    // {queryName: 'full_snomed', schemaName: 'ehr_lookups', title: 'Full SNOMED Set'},
                    // {queryName: 'snomap', schemaName: 'ehr_lookups', title: 'SNOMED Old/New Code Mapping'},
                    // {queryName: 'snomed_qualifiers', schemaName: 'ehr_lookups', title: 'SNOMED Qualifiers'},
                    // {queryName: 'snomed_subsets', schemaName: 'ehr_lookups', title: 'SNOMED Subsets'},
                    // {queryName: 'snomed_subset_codes', schemaName: 'ehr_lookups', title: 'SNOMED Subset Codes'},
                    {queryName: 'validAccounts', schemaName: 'snprc_ehr', title: 'Account List'},
                    {queryName: 'AccountGroups', schemaName: 'ehr_lookups', title: 'Account Groups'},
                    {queryName: 'chargeBySpeciesTypes', schemaName: 'ehr_lookups', title: 'Charge by Species Types'},
                    {queryName: 'ValidDiet', schemaName: 'snprc_ehr', title: 'Valid Diets'},
                    {queryName: 'fee_schedule_type', schemaName: 'ehr_lookups', title: 'Fee Schedule Types'},
                    {queryName: 'assignment_status', schemaName: 'ehr_lookups', title: 'IACUC Assignment Status'},
                    {queryName: 'notes_category', schemaName: 'ehr_lookups', title: 'Notes Categories'},
                    {queryName: 'problem_list_category', schemaName: 'ehr_lookups', title: 'Problem List Category (Not used)'},
                    {queryName: 'species', schemaName: 'snprc_ehr', title: 'Species codes (Three-character)'},
                    {queryName: 'species_codes', schemaName: 'ehr_lookups', title: 'Species Codes (Two-character)'},
                    {queryName: 'speciesCommonNames', schemaName: 'ehr_lookups', title: 'Species Common Names (Two-character)'},
                    {queryName: 'ValidChargeBySpecies', schemaName: 'snprc_ehr', title: 'Species Based ChargeIds'},
                    {queryName: 'weight_ranges', schemaName: 'ehr_lookups', title: 'Weight: Min/Max Allowable Per Species'}

                ]
            }];

            Ext4.create('LDK.panel.NavPanel', menuCfg1);
            Ext4.create('LDK.panel.NavPanel', menuCfg2);
            Ext4.create('LDK.panel.NavPanel', menuCfg3);
        }
    });

</script>

