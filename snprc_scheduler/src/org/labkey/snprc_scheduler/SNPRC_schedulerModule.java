package org.labkey.snprc_scheduler;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.ehr.EHRService;
import org.labkey.api.module.DefaultModule;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.query.DefaultSchema;
import org.labkey.api.query.QuerySchema;
import org.labkey.api.resource.Resource;
import org.labkey.api.security.roles.RoleManager;
import org.labkey.api.services.ServiceRegistry;
import org.labkey.api.snprc_scheduler.SNPRC_schedulerService;
import org.labkey.api.view.BaseWebPartFactory;
import org.labkey.api.view.Portal;
import org.labkey.api.view.ViewContext;
import org.labkey.api.view.WebPartFactory;
import org.labkey.api.view.WebPartView;
import org.labkey.snprc_scheduler.security.SNPRC_schedulerAdminRole;
import org.labkey.snprc_scheduler.security.SNPRC_schedulerEditorsRole;
import org.labkey.snprc_scheduler.security.SNPRC_schedulerReadersRole;
import org.labkey.snprc_scheduler.security.SNPRC_schedulerReviewersRole;
import org.labkey.snprc_scheduler.services.SNPRC_schedulerServiceImpl;
import org.labkey.snprc_scheduler.view.SchedulerWebPart;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Set;

public class SNPRC_schedulerModule extends DefaultModule
{
    public static final String NAME = "SNPRC_scheduler";

    @Override
    public String getName()
    {
        return NAME;
    }

    @Override
    public @Nullable Double getSchemaVersion()
    {
        return 23.00;
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
        Collection<WebPartFactory> webPartFactories = new ArrayList<>();
        webPartFactories.add(new BaseWebPartFactory("SNPRC Scheduler", WebPartFactory.LOCATION_BODY, WebPartFactory.LOCATION_RIGHT)
        {
            @Override
            public WebPartView getWebPartView(@NotNull ViewContext portalCtx, @NotNull Portal.WebPart webPart)
            {
                return new SchedulerWebPart();
            }
        });

        return webPartFactories;
    }


    @Override
    protected void init()
    {

        addController(SNPRC_schedulerController.NAME, SNPRC_schedulerController.class);

        ServiceRegistry.get().registerService(SNPRC_schedulerService.class, SNPRC_schedulerServiceImpl.INSTANCE);

        // Security Roles
        RoleManager.registerRole(new SNPRC_schedulerReadersRole(), false);
        RoleManager.registerRole(new SNPRC_schedulerEditorsRole(), false);
        RoleManager.registerRole(new SNPRC_schedulerReviewersRole(), false);
        RoleManager.registerRole(new SNPRC_schedulerAdminRole(), false);
    }

    @Override
    public void doStartup(ModuleContext moduleContext)
    {
        // add a container listener so we'll know when our container is deleted:
        ContainerManager.addContainerListener(new SNPRC_schedulerContainerListener());

        Resource r = getModuleResource("/scripts/snprc_scheduler_triggers.js");
        assert r != null;
        EHRService.get().registerTriggerScript(this, r);

        DefaultSchema.registerProvider(SNPRC_schedulerSchema.NAME, new DefaultSchema.SchemaProvider(this)
        {
            @Override
            public QuerySchema createSchema(final DefaultSchema schema, Module module)
            {
                return new SNPRC_schedulerUserSchema(SNPRC_schedulerSchema.NAME, null, schema.getUser(), schema.getContainer(), SNPRC_schedulerSchema.getInstance().getSchema());
            }
        });

//
//        for (final String schemaName : getSchemaNames())
//        {
//            final DbSchema dbSchema = DbSchema.get(schemaName, DbSchemaType.Module);
//            DefaultSchema.registerProvider(dbSchema.getQuerySchemaName(), new DefaultSchema.SchemaProvider(this)
//            {
//                public QuerySchema createSchema(final DefaultSchema schema, Module module)
//                {
//                    DbSchema dbSchema = DbSchema.get(schemaName, DbSchemaType.Module);
//                    return QueryService.get().createSimpleUserSchema(dbSchema.getQuerySchemaName(), null, schema.getUser(), schema.getContainer(), dbSchema);
//                }
//            });
//        }
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
        return Collections.singleton(SNPRC_schedulerSchema.NAME);
    }
}