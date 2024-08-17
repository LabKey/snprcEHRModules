package org.labkey.snprc_ehr.steps;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.EmptyStackException;
import java.util.Stack;
import java.util.LinkedHashMap;
import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.di.TaskRefTaskImpl;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.RecordedActionSet;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.ValidationError;
import org.labkey.api.snd.SNDService;
import org.labkey.api.snd.SuperPackage;
import org.labkey.snprc_ehr.SNPRC_EHRSchema;
import org.labkey.snprc_ehr.services.SNPRC_EHRUtils;


import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class SuperPackageLoadTask extends TaskRefTaskImpl
{

    private void importSuperPackages(PipelineJob job) throws PipelineJobException
    {
        try
        {
            // read in the superPackage table
            UserSchema schema = QueryService.get().getUserSchema(job.getUser(), job.getContainer(), SNPRC_EHRSchema.NAME);
            if (schema == null)
            {
                throw new PipelineJobException("Could not find schema " + schema + " in " + job.getContainer().getPath());
            }

            TableInfo ti = schema.getTable(SNPRC_EHRSchema.TABLE_SND_SUPER_PACKAGE_STAGING, schema.getDefaultContainerFilter());
            if (ti == null)
            {
                throw new PipelineJobException("Could not find table " + SNPRC_EHRSchema.TABLE_SND_SUPER_PACKAGE_STAGING + " in " + job.getContainer().getPath());
            }

            Sort sort = new Sort();
            sort.appendSortColumn(FieldKey.fromString("TopLevelPkgId"), Sort.SortDirection.ASC, false);
            sort.appendSortColumn(FieldKey.fromString("TreePath"), Sort.SortDirection.ASC, false);

            // get all super packages that have been uploaded in the last 15 minutes
            String formattedDateTime = SNPRC_EHRUtils.get().getQueryDateTime(-15);
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("diModified"), formattedDateTime, CompareType.GTE);

            TableSelector ts = new TableSelector(ti, filter, sort);
            List<SuperPackage> superPackages = ts.getArrayList(SuperPackage.class);

            if (superPackages == null || superPackages.size() == 0)
            {
                job.getLogger().info("No new super packages found in " + SNPRC_EHRSchema.TABLE_SND_SUPER_PACKAGE_STAGING);
                return;
            }

            LinkedHashMap<Integer, List<SuperPackage>> hierarchicalPackages = new LinkedHashMap<>();
            // group super packages ordered by top level package id
            Map<Integer, List<SuperPackage>> superPackagesByTopLevelPkgId = superPackages.stream()
                    .collect(Collectors.groupingBy(SuperPackage::getTopLevelPkgId, LinkedHashMap::new, Collectors.toList()));

            job.getLogger().info("Number of super packages: " + superPackagesByTopLevelPkgId.size());

            superPackagesByTopLevelPkgId.forEach((topLevelPkgId, sp) -> {
                job.getLogger().info("Processing Super Package: " + topLevelPkgId);
                try
                {
                    hierarchicalPackages.put(topLevelPkgId, buildHierarchicalPackages(sp, job));
                }
                catch (RuntimeException e)
                {
                    job.getLogger().info("Skipping package: " + topLevelPkgId);
                }
                catch (PipelineJobException e)
                {
                    job.getLogger().info("Error processing package: " + topLevelPkgId);
                    throw new RuntimeException(e.getMessage(), e);
                }
            });

            hierarchicalPackages.forEach((topLevelPkgId, sp) -> {
                job.getLogger().info("Saving Super Package: " + topLevelPkgId + "-" + sp.get(0).getDescription());
                SNDService.get().saveSuperPackages(job.getContainer(), job.getUser(), sp);
            });
        }
        catch (Exception e)
        {
            job.getLogger().error("Error importing super packages: " + e.getMessage());
            throw e;
        }
    }

    private List<SuperPackage> buildHierarchicalPackages(List<SuperPackage> superPackages, PipelineJob job) throws PipelineJobException
    {
        try
        {
            Stack<SuperPackage> parent = new Stack<>();
            List<SuperPackage> hierarchicalPackage = new ArrayList<>();

            List<SuperPackage> sortedSuperPackages = superPackages.stream().sorted(Comparator.comparing(SuperPackage::getTreePath))
                    .collect(Collectors.toList());

            sortedSuperPackages.stream().forEachOrdered(subPackage ->
            {
                // add package object to childSuperPackage
                subPackage.setPkg(SNDService.get().getPackages(job.getContainer(), job.getUser(), Collections.singletonList(subPackage.getPkgId()), true, true, true).get(0));

                if (subPackage.getParentSuperPkgId() == null)
                {
                    parent.push(subPackage);
                }
                else
                {
                    while (subPackage.getParentSuperPkgId().intValue() != parent.peek().getSuperPkgId().intValue())
                    {
                        parent.pop();
                    }
                    if (parent.peek().getChildPackages() == null)
                        parent.peek().setChildPackages(new ArrayList<>());

                    parent.peek().getChildPackages().add(subPackage);
                    parent.push(subPackage);
                }
            });
            while (parent.size() > 1)
            {
                parent.pop();
            }

            hierarchicalPackage.add(parent.pop());
            return hierarchicalPackage;
        }
        catch (EmptyStackException e)
        {
            job.getLogger().info("Not enough information to build hierarchical package: " + superPackages.get(0).getTopLevelPkgId());
            throw new RuntimeException(e.getMessage(), e);
        }
        catch (Exception e)
        {
            job.getLogger().info("Error while building hierarchical package: " + e.getMessage(), e);
            throw new PipelineJobException(e.getMessage(), e);
        }
    }
    
    @Override
    public RecordedActionSet run(@NotNull PipelineJob job)
    {
        try {
            importSuperPackages(job);
        }
        catch (Exception e) {
            job.getLogger().error(e.getMessage(), e);
        }
        return new RecordedActionSet(makeRecordedAction());
    }

    @Override
    public List<ValidationError> preFlightCheck(Container c)
    {
        return super.preFlightCheck(c);
    }
}
