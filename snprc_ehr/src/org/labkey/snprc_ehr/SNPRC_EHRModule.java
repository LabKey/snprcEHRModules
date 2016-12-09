/*
 * Copyright (c) 2014-2016 LabKey Corporation
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

package org.labkey.snprc_ehr;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Container;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.DefaultDataEntryFormFactory;
import org.labkey.api.ehr.demographics.ActiveFlagsDemographicsProvider;
import org.labkey.api.ehr.history.DefaultNotesDataSource;
import org.labkey.api.ehr.history.DefaultTBDataSource;
import org.labkey.api.ehr.history.DefaultVitalsDataSource;
import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.ldk.notification.NotificationService;
import org.labkey.api.module.AdminLinkManager;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.WebPartFactory;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.snprc_ehr.dataentry.dataentry.ArrivalFormType;
import org.labkey.snprc_ehr.dataentry.dataentry.BirthFormType;
import org.labkey.snprc_ehr.dataentry.dataentry.FlagsFormType;
import org.labkey.snprc_ehr.demographics.ActiveAnimalGroupsDemographicsProvider;
import org.labkey.snprc_ehr.demographics.ActiveAssignmentsDemographicsProvider;
import org.labkey.snprc_ehr.demographics.ActiveCasesDemographicsProvider;
import org.labkey.snprc_ehr.demographics.BirthDemographicsProvider;
import org.labkey.snprc_ehr.demographics.CurrentAccountsDemographicsProvider;
import org.labkey.snprc_ehr.demographics.CurrentDietDemographicsProvider;
import org.labkey.snprc_ehr.demographics.CurrentPedigreeDemographicsProvider;
import org.labkey.snprc_ehr.demographics.DeathsDemographicsProvider;
import org.labkey.snprc_ehr.demographics.IdHistoryDemographicsProvider;
import org.labkey.snprc_ehr.demographics.ParentsDemographicsProvider;
import org.labkey.snprc_ehr.demographics.TBDemographicsProvider;
import org.labkey.snprc_ehr.history.DietDataSource;
import org.labkey.snprc_ehr.history.LabResultsLabworkType;
import org.labkey.snprc_ehr.history.OffspringDataSource;
import org.labkey.snprc_ehr.notification.SampleSSRSNotification;
import org.labkey.snprc_ehr.table.SNPRC_EHRCustomizer;

import java.util.Collection;
import java.util.Collections;
import java.util.Set;

public class SNPRC_EHRModule extends ExtendedSimpleModule
{
    public static final String NAME = "SNPRC_EHR";

    @Override
    public String getName()
    {
        return NAME;
    }

    @Override
    public double getVersion()
    {
        return 16.32;
    }

    @Override
    public boolean hasScripts()
    {
        return true;
    }

    @Override
    @NotNull
    protected Collection<WebPartFactory> createWebPartFactories()
    {
        return Collections.emptyList();
    }

    @Override
    protected void init()
    {
        addController(SNPRC_EHRController.NAME, SNPRC_EHRController.class);
    }

    @Override
    protected void doStartupAfterSpringConfig(ModuleContext moduleContext)
    {
        EHRService.get().registerModule(this);

        EHRService.get().registerClientDependency(ClientDependency.fromPath("snprc_ehr/panel/BloodSummaryPanel.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("snprc_ehr/panel/ColonyUsage.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("snprc_ehr/snprcReports.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("snprc_ehr/snprcOverrides.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("snprc_ehr/demographicsRecord.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.fromPath("ehr/reports.js"), this);

        EHRService.get().registerActionOverride("colonyOverview", this, "views/colonyOverview.html");
        EHRService.get().registerActionOverride("projectQueries", this, "views/projectQueries.html");
        EHRService.get().registerActionOverride("protocolDetails", this, "views/protocolDetails.html");
        EHRService.get().registerActionOverride("animalHistory", this, "views/animalHistory.html");
        EHRService.get().registerTableCustomizer(this, SNPRC_EHRCustomizer.class);

        EHRService.get().registerDemographicsProvider(new TBDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ActiveFlagsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new IdHistoryDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ActiveAnimalGroupsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new CurrentAccountsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ActiveCasesDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new CurrentPedigreeDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ActiveAssignmentsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new CurrentDietDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new BirthDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new DeathsDemographicsProvider(this));

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Mature Female Exposed To Fertile Male", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr&query.queryName=animalExposure"), "Colony Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.housing, "Find Animals Housed In A Given Room/Cage At A Specific Time", this, DetailsURL.fromString("/ehr/housingOverlaps.view?groupById=1"), "Commonly Used Queries");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Population Summary By Species, Gender and Age", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=study&query.queryName=colonyPopulationByAge"), "Other Searches");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Find Animals Housed At The Center Over A Date Range", this, DetailsURL.fromString("/ehr/housingOverlaps.view?groupById=1"), "Other Searches");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.protocol, "View All Active Protocols", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr&query.queryName=Protocol&query.viewName=Active Protocols"), "Quick Links");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.protocol, "View All Protocols With Active Assignments", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr&query.queryName=Protocol&query.viewName=Protocols With Active Assignments"), "Quick Links");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.project, "View Active Projects", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr&query.queryName=Project&query.viewName=Active Projects"), "Quick Links");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Listing of Cages", this, DetailsURL.fromString("/query/executeQuery.view?schemaName=ehr_lookups&query.queryName=cage"), "Colony Management");

        // Add ehr clinical history data sources
        EHRService.get().registerHistoryDataSource(new DefaultVitalsDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultTBDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultNotesDataSource(this));

        // Add SNPRC clinical history data sources
        EHRService.get().registerHistoryDataSource(new DietDataSource(this));
        EHRService.get().registerHistoryDataSource(new OffspringDataSource(this));

        // Add SNPRC Labwork type
        EHRService.get().registerLabworkType(new LabResultsLabworkType(this));

        // demographics
        EHRService.get().registerDemographicsProvider(new ParentsDemographicsProvider(this));

        NotificationService.get().registerNotification(new SampleSSRSNotification());

        AdminLinkManager.getInstance().addListener(new AdminLinkManager.Listener()
        {
            @Override
            public void addAdminLinks(NavTree adminNavTree, Container container, User user)
            {
                if (container.hasPermission(user, AdminPermission.class) && container.getActiveModules().contains(SNPRC_EHRModule.this))
                {
                    adminNavTree.addChild(new NavTree("EHR Admin Page", new ActionURL("snprc_ehr", "ehrAdmin", container)));
                }
            }
        });

//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(WeightFormType.class, this));
        //EHRService.get().registerFormType(new DefaultDataEntryFormFactory(AnesthesiaFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(DCMNotesFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ClinicalRoundsFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(SurgicalRoundsFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BehaviorExamFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BehaviorRoundsFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(TreatmentsFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(MedSignoffFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(TBFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(PairingFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(LabworkFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(IStatFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ProcessingFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(SurgeryFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(SingleSurgeryFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(NecropsyFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BiopsyFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(PathologyTissuesFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ClinicalReportFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BulkClinicalEntryFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(DeathFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(MensFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(AssignmentFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(GroupAssignmentFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BirthFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ArrivalFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(DepartureFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(FlagsFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(HousingFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(MatingFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(PregnancyConfirmationFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ParentageFormType.class, this));

//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BloodDrawFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(AuxProcedureFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ASBRequestFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(ColonyRequestFormType.class, this));
//        // Requires mergesync
          // EHRService.get().registerFormType(new DefaultDataEntryFormFactory(LabworkRequestFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(HousingRequestFormType.class, this));

//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(BloodRequestBulkEditFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(DrugRequestBulkEditFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(LabworkRequestBulkEditFormType.class, this));

//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(RecordAmendmentFormType.class, this));

    }

    @Override
    @NotNull
    public Collection<String> getSummary(Container c)
    {
        return Collections.emptyList();
    }

    @Override
    @NotNull
    public Set<String> getSchemaNames()
    {
        return Collections.singleton(SNPRC_EHRSchema.NAME);
    }
}