package org.labkey.snprc_ehr.snd.triggers;

import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.EHRDemographicsService;
import org.labkey.api.ehr.demographics.AnimalRecord;
import org.labkey.api.gwt.client.model.GWTPropertyDescriptor;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;
import org.labkey.api.snd.AttributeData;
import org.labkey.api.snd.Event;
import org.labkey.api.snd.EventData;
import org.labkey.api.snd.Package;
import org.labkey.api.snd.SuperPackage;

import java.util.List;
import java.util.Map;

public class TriggerHelper
{
    // Properties can be passed in by name or propertyId. This will get the propertyId from the package for a given
    // attribute name.
    public static Integer getPropertyId(String name, Package pkg)
    {
        Integer propertyId = null;
        for (GWTPropertyDescriptor attribute : pkg.getAttributes())
        {
            if (attribute.getName().equals(name))
            {
                propertyId = attribute.getPropertyId();
                break;
            }
        }

        return propertyId;
    }

    public static AttributeData getAttribute(String name, EventData eventData, Package pkg)
    {
        Integer attributePropId = getPropertyId(name, pkg);

        AttributeData attribute = null;

        for (AttributeData attributeData : eventData.getAttributes())
        {
            if ((attributeData.getPropertyName() != null && attributeData.getPropertyName().equals(name))
                    || (attributePropId != null && attributeData.getPropertyId() == attributePropId))
            {
                attribute = attributeData;
            }
        }

        return attribute;
    }

    public static void setAttributeValue(EventData eventData, @Nullable Integer propertyId, @Nullable String propertyName, String value)
    {
        for (AttributeData attributeData : eventData.getAttributes())
        {
            if ((attributeData.getPropertyName() != null && attributeData.getPropertyName().equals(propertyName))
                    || (propertyId != null && attributeData.getPropertyId() == propertyId))
            {
                attributeData.setValue(value);
            }
        }
    }

    public static void saveAttributeData(EventData eventData, String propertyName, String propertyValue)
    {
        boolean found = false;
        for (AttributeData attributeData : eventData.getAttributes())
        {
            if ((attributeData.getPropertyName() != null && attributeData.getPropertyName().equals(propertyName)))
            {
                attributeData.setValue(propertyValue);
                found = true;
                break;
            }
        }

        if (!found)
        {
            eventData.getAttributes().add(new AttributeData(propertyName, null, propertyValue));
        }
    }

    public static TableInfo getTableInfo(Container container, User user, String schema, String query, List<ValidationException> errors)
    {
        UserSchema us = QueryService.get().getUserSchema(user, container, schema);
        if (us == null)
        {
            errors.add(new ValidationException("User schema " + schema + " not found."));
            return null;
        }

        TableInfo ti = us.getTable(query);
        if (ti == null)
        {
            errors.add(new ValidationException("Unable to find table: " + schema + "." + query));
            return null;
        }

        return ti;
    }

    @Nullable
    public static String getGender(Container c, String subjectId, List<ValidationException> errors)
    {
        String gender = null;

        AnimalRecord ar = EHRDemographicsService.get().getAnimal(c, subjectId);
        if (ar == null)
        {
            errors.add(new ValidationException("Animal Id not found", ValidationException.SEVERITY.ERROR));
            return gender;
        }

        return ar.getGender();
    }

    public static boolean verifyGender(Container c, String subjectId, String expectedGender, List<ValidationException> errors)
    {
        return expectedGender.equals(getGender(c, subjectId, errors));
    }

    private static SuperPackage getSuperPackage(int superPkgId, List<SuperPackage> superPkgs)
    {
        for (SuperPackage superPkg : superPkgs)
        {
            if (superPkg.getSuperPkgId() != null && superPkg.getSuperPkgId() == superPkgId)
            {
                return superPkg;
            }
        }

        return null;
    }

    private static boolean eventDataHasCategory(String category, EventData eventData, SuperPackage superPackage)
    {
        boolean found = false;

        if (superPackage.getPkg() != null)
        {
            // First check current event data
            if (superPackage.getPkg().getCategories().containsValue(category))
            {
                found = true;
            }
            // Then check subpackages
            else if (eventData.getSubPackages() != null)
            {
                for (EventData data : eventData.getSubPackages())
                {
                    if (eventDataHasCategory(category, data, getSuperPackage(data.getSuperPkgId(), superPackage.getChildPackages())))
                    {
                        found = true;
                        break;
                    }
                }
            }
        }

        return found;
    }

    public static boolean eventHasDataWithCategory(String category, Event event, Map<Integer, SuperPackage> superPackages)
    {
        boolean found = false;

        if (event != null && event.getEventData() != null)
        {
            for (EventData eventData : event.getEventData())
            {
                if (eventDataHasCategory(category, eventData, superPackages.get(eventData.getEventDataId())))
                {
                    found = true;
                    break;
                }

            }
        }

        return found;
    }
}