package org.labkey.snprc_ehr.steps;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.di.TaskRefTaskImpl;
import org.labkey.api.exp.Lsid;
import org.labkey.api.exp.property.DefaultPropertyValidator;
import org.labkey.api.gwt.client.model.GWTPropertyDescriptor;
import org.labkey.api.gwt.client.model.GWTPropertyValidator;
import org.labkey.api.gwt.client.model.PropertyValidatorType;
import org.labkey.api.pipeline.PipelineJob;
import org.labkey.api.pipeline.PipelineJobException;
import org.labkey.api.pipeline.RecordedActionSet;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.ValidationError;
import org.labkey.api.snd.Package;
import org.labkey.api.snd.SNDService;
import org.labkey.api.util.DateUtil;
import org.labkey.snprc_ehr.SNPRC_EHRManager;
import org.labkey.snprc_ehr.SNPRC_EHRSchema;
import org.labkey.snprc_ehr.services.SNPRC_EHRUtils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class PackageLoadTask extends TaskRefTaskImpl
{

    private void importPackages( PipelineJob job) throws PipelineJobException
    {
        try
        {
            // read in the package table and create package objects
            UserSchema schema = QueryService.get().getUserSchema(job.getUser(), job.getContainer(), SNPRC_EHRSchema.NAME);
            if (schema == null) { throw new PipelineJobException("Could not find schema " + schema + " in " + job.getContainer().getPath());  }

            TableInfo ti = schema.getTable(SNPRC_EHRSchema.TABLE_SND_PACKAGE_STAGING, schema.getDefaultContainerFilter());
            if (ti == null ) { throw new PipelineJobException("Could not find table " + SNPRC_EHRSchema.TABLE_SND_PACKAGE_STAGING + " in " + job.getContainer().getPath());  }

            // get packages uploaded in the last 15 minutes
            String formattedDateTime = SNPRC_EHRUtils.get().getQueryDateTime(-15);
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("diModified"), formattedDateTime, CompareType.GTE);

            TableSelector ts = new TableSelector(ti, filter, null);
            Map<String, Object>[] rows = ts.getMapArray();

            if (rows == null || rows.length == 0) {
                job.getLogger().info("No new packages found in " + SNPRC_EHRSchema.TABLE_SND_PACKAGE_STAGING);
                return;
            }

            job.getLogger().info("Number of packages: " + rows.length);
            for (Map<String, Object> row : rows) {
                // build package
                Package pkg = buildPackage(row, job);
                job.getLogger().info("Processing Package: " + pkg.getPkgId() + "-" + pkg.getDescription());
                // add attributes to package
                List<GWTPropertyDescriptor> attributeDataList = getAttributes(pkg.getPkgId(), job);
                if (attributeDataList != null && !attributeDataList.isEmpty())
                {
                    pkg.setAttributes(attributeDataList);
                }
                // save package
                SNDService.get().savePackage(job.getContainer(), job.getUser(), pkg, null, false, true);
            }

        }
        catch (Exception e) {
            job.getLogger().error ("Error reading package table: " + e.getMessage());
            throw new PipelineJobException(e);
        }
    }

    private Package buildPackage(Map<String, Object> row, PipelineJob job) throws PipelineJobException
    {
        Package pkg = new Package();
        try
        {
            //Id
            pkg.setPkgId(row.get("PkgId") == null ? null : Integer.parseInt(row.get("PkgId").toString()));

            //description
            pkg.setDescription(row.get("Description") == null ? null : row.get("Description").toString());

            //repeatable
            pkg.setRepeatable(row.get("Repeatable") == null ? null : Boolean.parseBoolean(row.get("Repeatable").toString()));

            //displayable
            pkg.setActive(row.get("Active") == null ? null : Boolean.parseBoolean(row.get("Active").toString()));

            /* extra field(s)*/
            //usda-category
            String usdaCategory = row.get("UsdaCategory") == null ? "U" : row.get("UsdaCategory").toString();
            Map<GWTPropertyDescriptor, Object> extraFields = new HashMap<>();

            //usda-category
            GWTPropertyDescriptor gwtpd = new GWTPropertyDescriptor();
            gwtpd.setName("usdaCode");
            gwtpd.setRangeURI("http://www.w3.org/2001/XMLSchema#string");
            extraFields.put(gwtpd, usdaCategory);
            pkg.setExtraFields(extraFields);

            //narrative
            pkg.setNarrative(row.get("Narrative") == null ? null : row.get("Narrative").toString());
        }
        catch (Exception e)
        {
            job.getLogger().error("Error building package: " + e.getMessage());
            throw new PipelineJobException(e);
        }
        return pkg;
    }

    private List<GWTPropertyDescriptor> getAttributes(int pkgId, PipelineJob job) throws PipelineJobException
    {
        List<GWTPropertyDescriptor> attributesList = new ArrayList<>();
        try
        {
            UserSchema schema = QueryService.get().getUserSchema(job.getUser(), job.getContainer(), SNPRC_EHRSchema.NAME);
            if (schema == null)
            {
                throw new IllegalArgumentException("Could not find schema " + schema + " in " + job.getContainer().getPath());
            }

            TableInfo ti = schema.getTable(SNPRC_EHRSchema.TABLE_SND_PACKAGE_ATTRIBUTES_STAGING, schema.getDefaultContainerFilter(), true, false);
            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("PkgId"), pkgId, CompareType.EQUAL);
            TableSelector ts = new TableSelector(ti, filter, null);
            Map<String, Object>[] attributes = ts.getMapArray();

            if (attributes == null || attributes.length == 0)
            {
                return null;
            }

            for (Map<String, Object> attribute : attributes)
            {
                GWTPropertyDescriptor gwtpd = new GWTPropertyDescriptor();

                String rangeURI = attribute.get("RangeURI") == null ? null : attribute.get("RangeURI").toString();
                String colunmName = attribute.get("AttributeName") == null ? null : attribute.get("AttributeName").toString();

                //columnName
                gwtpd.setName(colunmName);

                //rangeURI
                gwtpd.setRangeURI(rangeURI);

                //nullable
                gwtpd.setRequired(attribute.get("Required") == null ? null : Boolean.parseBoolean(attribute.get("Required").toString()));

                //columnTitle
                gwtpd.setLabel(attribute.get("Label") == null ? null : attribute.get("Label").toString());

                // format for decimals
                if (rangeURI.contains("double"))
                    gwtpd.setFormat("0.##");

                //fk
                String lookupTable  = attribute.get("LookupQuery") == null ? null : attribute.get("LookupQuery").toString();
                if (lookupTable != null)
                {
                    //defaultValue
                    if (attribute.get("defaultValue") != null && attribute.get("lookupSchema") != null && attribute.get("lookupQuery") != null)
                    {
                        Object defaultValue = SNDService.get().normalizeLookupValue(job.getUser(), job.getContainer(),
                                attribute.get("lookupSchema").toString(), attribute.get("lookupQuery").toString(), attribute.get("defaultValue").toString());
                        if (defaultValue != null)
                        {
                            gwtpd.setDefaultValue(defaultValue.toString());
                        }
                    }
                    else
                    {
                        gwtpd.setDefaultValue(attribute.get("DefaultValue") == null ? null : attribute.get("DefaultValue").toString());
                    }

                    gwtpd.setLookupQuery(attribute.get("LookupQuery") == null ? null : attribute.get("LookupQuery").toString());
                    gwtpd.setLookupSchema(attribute.get("LookupSchema") == null ? null : attribute.get("LookupSchema").toString());
                }
                else {
                    gwtpd.setDefaultValue(attribute.get("DefaultValue") == null ? null : attribute.get("DefaultValue").toString());
                }

                //scale
                gwtpd.setScale(0);

                //redactedText
                gwtpd.setRedactedText(attribute.get("AlternateText") == null ? null : attribute.get("AlternateText").toString());

                //validator
                String validatorExpression = attribute.get("ValidatorExpression") == null ? null : attribute.get("ValidatorExpression").toString();
                if (validatorExpression != null)
                {
                    List<GWTPropertyValidator> gwtPropertyValidatorList = new LinkedList<>();

                    GWTPropertyValidator gwtPropertyValidator = new GWTPropertyValidator();
                    gwtPropertyValidator.setName("Range"); // columnname: RangeURI
                    gwtPropertyValidator.setExpression(validatorExpression); //expression

                    // Default Property Validator type to "Range"
                    String typeUri = DefaultPropertyValidator.createValidatorURI(PropertyValidatorType.Range).toString();
                    Lsid lsid = new Lsid(typeUri);
                    gwtPropertyValidator.setType(PropertyValidatorType.getType(lsid.getObjectId()));
                    gwtPropertyValidatorList.add(gwtPropertyValidator);
                    gwtpd.setPropertyValidators(gwtPropertyValidatorList);

                }
                attributesList.add(gwtpd);
            }
        }
        catch (Exception e)
        {
            job.getLogger().error("Error building package attributes: " + e.getMessage());
            throw new PipelineJobException(e);
        }
        return attributesList;
    }

    @Override
    public RecordedActionSet run(@NotNull PipelineJob job)
    {
        try
        {
            importPackages(job);
        }
        catch (Exception e)
        {
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
