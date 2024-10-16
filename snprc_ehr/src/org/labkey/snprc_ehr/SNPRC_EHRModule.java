/*
 * Copyright (c) 2014-2019 LabKey Corporation
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
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.ObjectFactory;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.ehr.dataentry.DefaultDataEntryFormFactory;
import org.labkey.api.ehr.history.DefaultArrivalDataSource;
import org.labkey.api.ehr.history.DefaultNotesDataSource;
import org.labkey.api.ehr.history.DefaultTBDataSource;
import org.labkey.api.ehr.history.DefaultVitalsDataSource;
import org.labkey.api.ldk.ExtendedSimpleModule;
import org.labkey.api.ldk.notification.NotificationService;
import org.labkey.api.module.AdminLinkManager;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.pipeline.PipelineService;
import org.labkey.api.query.DefaultSchema;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.QuerySchema;
import org.labkey.api.resource.Resource;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.api.security.roles.RoleManager;
import org.labkey.api.snd.SNDService;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.BaseWebPartFactory;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.Portal;
import org.labkey.api.view.ViewContext;
import org.labkey.api.view.WebPartFactory;
import org.labkey.api.view.WebPartView;
import org.labkey.api.view.template.ClientDependency;
import org.labkey.snprc_ehr.buttons.SnprcUserEditButton;
import org.labkey.snprc_ehr.controllers.AnimalGroupsController;
import org.labkey.snprc_ehr.controllers.AnimalsHierarchyController;
import org.labkey.snprc_ehr.controllers.FeeScheduleController;
import org.labkey.snprc_ehr.dataentry.dataentry.EditLookupTablesFormType;
import org.labkey.snprc_ehr.dataentry.dataentry.FlagsFormType;
import org.labkey.snprc_ehr.dataentry.dataentry.GroupsCategoriesFormType;
import org.labkey.snprc_ehr.demographics.ActiveAnimalGroupsDemographicsProvider;
import org.labkey.snprc_ehr.demographics.ActiveAssignmentsDemographicsProvider;
import org.labkey.snprc_ehr.demographics.ActiveCasesDemographicsProvider;
import org.labkey.snprc_ehr.demographics.ActiveFlagsDemographicsProvider;
import org.labkey.snprc_ehr.demographics.BirthDemographicsProvider;
import org.labkey.snprc_ehr.demographics.CurrentAccountsDemographicsProvider;
import org.labkey.snprc_ehr.demographics.CurrentDietDemographicsProvider;
import org.labkey.snprc_ehr.demographics.CurrentPedigreeDemographicsProvider;
import org.labkey.snprc_ehr.demographics.DeathsDemographicsProvider;
import org.labkey.snprc_ehr.demographics.IdHistoryDemographicsProvider;
import org.labkey.snprc_ehr.demographics.LastBcsDemographicsProvider;
import org.labkey.snprc_ehr.demographics.LastHousingDemographicsProvider;
import org.labkey.snprc_ehr.demographics.MhcSummaryDemographicsProvider;
import org.labkey.snprc_ehr.demographics.ParentsDemographicsProvider;
import org.labkey.snprc_ehr.demographics.TBDemographicsProvider;
import org.labkey.snprc_ehr.domain.AnimalGroup;
import org.labkey.snprc_ehr.domain.AnimalGroupCategory;
import org.labkey.snprc_ehr.domain.AnimalSpecies;
import org.labkey.snprc_ehr.history.AccountDataSource;
import org.labkey.snprc_ehr.history.DefaultAssignmentDataSource;
import org.labkey.snprc_ehr.history.DefaultBloodDrawDataSource;
import org.labkey.snprc_ehr.history.DefaultCasesCloseDataSource;
import org.labkey.snprc_ehr.history.DefaultCasesDataSource;
import org.labkey.snprc_ehr.history.DefaultDepartureDataSource;
import org.labkey.snprc_ehr.history.DefaultPregnanciesDataSource;
import org.labkey.snprc_ehr.history.DefaultTreatmentOrdersDataSource;
import org.labkey.snprc_ehr.history.DietDataSource;
import org.labkey.snprc_ehr.history.LabworkDataSource;
import org.labkey.snprc_ehr.history.LabworkType;
import org.labkey.snprc_ehr.history.OffspringDataSource;
import org.labkey.snprc_ehr.notification.SampleSSRSNotification;
import org.labkey.snprc_ehr.pipeline.FeeSchedulePipelineProvider;
import org.labkey.snprc_ehr.security.ManageGroupMembersRole;
import org.labkey.snprc_ehr.security.ManageLookupTablesRole;
import org.labkey.snprc_ehr.security.SNPRCColonyAdminRole;
import org.labkey.snprc_ehr.security.SNPRC_EHREditRole;
import org.labkey.snprc_ehr.snd.SNPRCEventTriggerFactory;
import org.labkey.snprc_ehr.table.SNPRC_EHRCustomizer;
import org.labkey.snprc_ehr.views.AnimalsHierarchyWebPart;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.Set;

//import org.labkey.snprc_ehr.views.FeeScheduleWebPart;

public class SNPRC_EHRModule extends ExtendedSimpleModule
{
    public static final String NAME = "SNPRC_EHR";

    @Override
    public String getName()
    {
        return NAME;
    }

    @Override
    public @Nullable Double getSchemaVersion()
    {
        return 24.002;
    }

    @Override
    public boolean hasScripts()
    {
        return true;
    }

    @Override
    protected void init()
    {
        addController(SNPRC_EHRController.NAME, SNPRC_EHRController.class);
        //Controllers
        addController(AnimalGroupsController.NAME.toLowerCase(), AnimalGroupsController.class);
        addController(AnimalsHierarchyController.NAME.toLowerCase(), AnimalsHierarchyController.class);
        addController(FeeScheduleController.NAME.toLowerCase(), FeeScheduleController.class);

        //additional roles
        RoleManager.registerRole(new ManageGroupMembersRole());
        RoleManager.registerRole(new ManageLookupTablesRole());
        RoleManager.registerRole(new SNPRC_EHREditRole());
        RoleManager.registerRole(new SNPRCColonyAdminRole());

        SNDService.get().registerEventTriggerFactory(this, new SNPRCEventTriggerFactory());

        //register factory beans to map foo_bar column names to fooBar
        ObjectFactory.Registry.register(AnimalGroup.class, new SNPRCBeanFactory<>(AnimalGroup.class));
        ObjectFactory.Registry.register(AnimalGroupCategory.class, new SNPRCBeanFactory<>(AnimalGroupCategory.class));
        ObjectFactory.Registry.register(AnimalSpecies.class, new SNPRCBeanFactory<>(AnimalSpecies.class));
    }

    @Override
    protected void doStartupAfterSpringConfig(ModuleContext moduleContext)
    {
        EHRService.get().registerModule(this);

        Resource r = getModuleResource("/scripts/snprc_triggers.js");
        assert r != null;
        EHRService.get().registerTriggerScript(this, r);

        // register MoreActions buttons

        EHRService.get().registerMoreActionsButton(new SnprcUserEditButton(this, "study", "flags", UpdatePermission.class),
                    "study", "flags");

        // register client dependencies
        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("snprc_ehr/panel/BloodSummaryPanel.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("snprc_ehr/panel/ClinicalHistoryPanel.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("snprc_ehr/panel/ColonyUsage.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("snprc_ehr/panel/EnterDataPanel.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("snprc_ehr/snprcReports.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("snprc_ehr/snprcOverrides.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("snprc_ehr/demographicsRecord.js"), this);
        EHRService.get().registerClientDependency(ClientDependency.supplierFromPath("ehr/reports.js"), this);

        // register action overrides
        EHRService.get().registerActionOverride("colonyOverview", this, "views/colonyOverview.html");
        EHRService.get().registerActionOverride("projectQueries", this, "views/projectQueries.html");
        EHRService.get().registerActionOverride("protocolDetails", this, "views/protocolDetails.html");
        EHRService.get().registerActionOverride("animalHistory", this, "views/animalHistory.html");
        EHRService.get().registerActionOverride("animalSearch", this, "views/animalSearch.html");
        EHRService.get().registerActionOverride("begin", this, "views/begin.html");
        EHRService.get().registerActionOverride("ehrAdmin", this, "views/ehrAdmin.html");
        EHRService.get().registerActionOverride("populateInitialData", this, "views/populateData.html");
        EHRService.get().registerActionOverride("enterData", this, "views/enterData.html");

        EHRService.get().registerTableCustomizer(this, SNPRC_EHRCustomizer.class);
        EHRService.get().registerDemographicsProvider(new IdHistoryDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ActiveAnimalGroupsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new CurrentAccountsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ActiveCasesDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new CurrentPedigreeDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ActiveAssignmentsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new CurrentDietDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new BirthDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new DeathsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new TBDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new ActiveFlagsDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new MhcSummaryDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new LastHousingDemographicsProvider(this));
        EHRService.get().registerDemographicsProvider(new LastBcsDemographicsProvider(this));

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.housing, "Find Animals Housed In A Given Room/Cage At A Specific Time", this, DetailsURL.fromString("/ehr-housingOverlaps.view?groupById=1"), "Commonly Used Queries");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Population Summary By Species, Gender and Age", this, DetailsURL.fromString("/query-executeQuery.view?schemaName=study&query.queryName=colonyPopulationByAge"), "Other Searches");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.animalSearch, "Find Animals Housed At The Center Over A Date Range", this, DetailsURL.fromString("/ehr-housingOverlaps.view?groupById=1"), "Other Searches");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.protocol, "View All Active Protocols", this, DetailsURL.fromString("/query-executeQuery.view?schemaName=ehr&query.queryName=Protocol&query.viewName=Active Protocols"), "Quick Links");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.protocol, "View All Protocols With Active Assignments", this, DetailsURL.fromString("/query-executeQuery.view?schemaName=ehr&query.queryName=Protocol&query.viewName=Protocols With Active Assignments"), "Quick Links");

        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.project, "View Active Projects", this, DetailsURL.fromString("/query-executeQuery.view?schemaName=ehr&query.queryName=Project&query.viewName=Active Projects"), "Quick Links");

        // Add to moreReports here
        //EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Listing of Cages", this, DetailsURL.fromString("/query-executeQuery.view?schemaName=ehr_lookups&query.queryName=cage"), "Colony Management");
        //EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Mature Female Exposed To Fertile Male", this, DetailsURL.fromString("/query-executeQuery.view?schemaName=ehr&query.queryName=animalExposure"), "Colony Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Due/Overdue TB Report", this, DetailsURL.fromString("/query-executeQuery.view?schemaName=study&query.queryName=overdueTb"), "Colony Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Search Apath History", this, DetailsURL.fromString("/query-executeQuery.view?schemaName=study&query.queryName=apathHistoryReport"), "Pathololgy");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Overall Behavior Report", this, DetailsURL.fromString("/query-executeQuery.view?schemaName=study&query.queryName=BehaviorReport"), "Behavior");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Birth Record Report", this, DetailsURL.fromString("/snprc_ehr-BirthReport.view"), "Colony Management");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "T cruzi New Positives Report",this,DetailsURL.fromString("/query-executeQuery.view?schemaName=study&query.queryName=ReportTcruziNewPositives"),"Surveillance");
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "T cruzi Summary Report",this,DetailsURL.fromString("/query-executeQuery.view?schemaName=study&query.queryName=ReportTcruziSummaryAll"),"Surveillance");

        // Add the current date to the chimp observation report
        SimpleDateFormat format = new SimpleDateFormat("MM-dd-yyyy");
        String date = format.format( new Date());
        String reportString = "/query-executeQuery.view?schemaName=study&query.queryName=DailyObs&query.viewName=DailyChimpObs&query.date~dateeq=" + date;
        EHRService.get().registerReportLink(EHRService.REPORT_LINK_TYPE.moreReports, "Chimp Observation Report", this,
                DetailsURL.fromString( reportString), "Clinical");

        // Add ehr clinical history data sources
        EHRService.get().registerHistoryDataSource(new AccountDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultArrivalDataSource(this));
//        EHRService.get().registerHistoryDataSource(new CycleDatasource(this)); // Removed for performance. Restructuring data.
        EHRService.get().registerHistoryDataSource(new DefaultDepartureDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultNotesDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultTBDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultVitalsDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultTreatmentOrdersDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultBloodDrawDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultAssignmentDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultCasesDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultCasesCloseDataSource(this));
        EHRService.get().registerHistoryDataSource(new DefaultPregnanciesDataSource(this));
        EHRService.get().registerHistoryDataSource(new LabworkDataSource(this));

        // Add SNPRC clinical history data sources
        EHRService.get().registerHistoryDataSource(new DietDataSource(this));
        EHRService.get().registerHistoryDataSource(new OffspringDataSource(this));

        // Add SNPRC Labwork type
        EHRService.get().registerLabworkType(new LabworkType(this));

        // demographics
        EHRService.get().registerDemographicsProvider(new ParentsDemographicsProvider(this));

        NotificationService.get().registerNotification(new SampleSSRSNotification());

        AdminLinkManager.getInstance().addListener((adminNavTree, container, user) -> {
            if (container.hasPermission(user, AdminPermission.class) && container.getActiveModules().contains(SNPRC_EHRModule.this))
            {
                adminNavTree.addChild(new NavTree("EHR Admin Page", new ActionURL("snprc_ehr", "ehrAdmin", container)));
            }
        });
        // Register pipeline provider to import FeeSchedule
        PipelineService.get().registerPipelineProvider(new FeeSchedulePipelineProvider(this));

        // SNPRC Data Entry Forms
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(FlagsFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(GroupsCategoriesFormType.class, this));
        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(EditLookupTablesFormType.class, this));

//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(WeightFormType.class, this));
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(AnesthesiaFormType.class, this));
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
//        EHRService.get().registerFormType(new DefaultDataEntryFormFactory(DepartureFormType.class, this));
        //this becomes a marker - EHR will display a link referencing this entry form
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


    @Override
    public void registerSchemas()
    {
        for (final String schemaName : getSchemaNames())
        {
            final DbSchema dbschema = DbSchema.get(schemaName);
            DefaultSchema.registerProvider(schemaName, new DefaultSchema.SchemaProvider(this)
            {
                @Override
                public QuerySchema createSchema(final DefaultSchema schema, Module module)
                {
                    if (schemaName.equalsIgnoreCase(SNPRC_EHRSchema.NAME)){
                        return new SNPRC_EHRUserSchema(schema.getUser(), schema.getContainer(), dbschema);
                    }

                    return null;
                }
            });
        }
    }

    @Override
    @NotNull
    protected Collection<WebPartFactory> createWebPartFactories()
    {
        Collection<WebPartFactory> webPartFactories = new ArrayList<>();
        webPartFactories.add(new BaseWebPartFactory("SNPRC Animals Treeview", WebPartFactory.LOCATION_BODY, WebPartFactory.LOCATION_RIGHT)
        {
            @Override
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                return new AnimalsHierarchyWebPart();
            }
        });
//        webPartFactories.add(new BaseWebPartFactory("SNPRC Fee Schedule Import", WebPartFactory.LOCATION_BODY, WebPartFactory.LOCATION_RIGHT)
//        {
//            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
//            {
//                return new FeeScheduleWebPart();
//            }
//        });

        return webPartFactories;
    }
}
