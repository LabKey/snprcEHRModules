package org.labkey.snprc_ehr.services;

import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;
import org.labkey.snprc_ehr.domain.NewAnimalData;

import java.util.Map;

public class SNPRC_EHRValidator
{
    public static void validateNewAnimalData(Container c, User u, NewAnimalData newAnimalData) throws ValidationException
    {
        // birthdate and acquisition dates
        if (newAnimalData.getBirthDate() == null)
            throw new ValidationException("Birthdate is required");
        if (newAnimalData.getAcqDate() == null)
            throw new ValidationException("Acquisition daate is required");
        if (newAnimalData.getBirthDate().after(newAnimalData.getAcqDate()))
            throw new ValidationException("Birthdate is greater than Acquisition date");

        // species

        try
        {
            if (newAnimalData.getSpecies() == null)
                throw new ValidationException("Species is required");

            // species exists - make sure it is valid
            Map<String, Object> row;
            UserSchema schema = QueryService.get().getUserSchema(u, c, "snprc_ehr");
            TableInfo ti = schema.getTable("CurrentSpeciesLookup", schema.getDefaultContainerFilter());
            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("SpeciesCode"), newAnimalData.getSpecies(), CompareType.EQUAL);
            TableSelector ts = new TableSelector(ti, filter, null);
            row = ts.getMap();
            //ts.getRowCount();
            //if (ts.getRowCount() != 1)

            if (row == null || !row.get("speciesCode").toString().equals(newAnimalData.getSpecies()))
                throw new ValidationException("Invalid Species code entered:" + newAnimalData.getSpecies());
        }
        catch (Exception e)
        {
            throw e;
        }


        // bdstatus
        if (newAnimalData.getBirthCode() == null)
            throw new ValidationException("Birthdate status is required");
        // acquisitionType
        if (newAnimalData.getAcquisitionType() == null)
            throw new ValidationException("Acquisition type is required");
        // gender
        if (newAnimalData.getGender() == null)
            throw new ValidationException("Gender is required");
        // sire

        // dam

        // colony

        // animalAccount
        if (newAnimalData.getAnimalAccount() == null)
            throw new ValidationException("Animal Account is required");
        // ownerInstitution
        if (newAnimalData.getOwnerInstitution() == null)
            throw new ValidationException("Owner Institution is required");
        //responsibleInstitution
        if (newAnimalData.getResponsibleInstitution() == null)
            throw new ValidationException("Responsible Institution is required");
        // room
        if (newAnimalData.getRoom() == null)
            throw new ValidationException("Room is required");
        // cage

        // diet
        if (newAnimalData.getDiet() == null)
            throw new ValidationException("Diet is required");
        // pedigree

        // IACUC
        if (newAnimalData.getIacuc() == null)
            throw new ValidationException("IACUC is required");
    }
}
