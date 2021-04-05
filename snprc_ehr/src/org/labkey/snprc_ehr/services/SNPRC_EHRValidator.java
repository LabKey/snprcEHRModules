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

import java.util.Date;
import java.util.Map;

public class SNPRC_EHRValidator
{
    public static void validateNewAnimalData(Container c, User u, NewAnimalData newAnimalData) throws ValidationException
    {
        String offSiteAcqCodes = "22, 23, 25, 97";
        // birthdate and acquisition dates
        if (newAnimalData.getBirthDate() == null)
            throw new ValidationException("Birthdate is required");
        if (newAnimalData.getAcqDate() == null)
            throw new ValidationException("Acquisition date is required");
        if (newAnimalData.getBirthDate().after(newAnimalData.getAcqDate()))
            throw new ValidationException("Birthdate is greater than Acquisition date");

        Map<String, Object> row;
        UserSchema schema = QueryService.get().getUserSchema(u, c, "snprc_ehr");
        UserSchema schemaEHR = QueryService.get().getUserSchema(u, c, "EHR");
        UserSchema schemaEHRLU = QueryService.get().getUserSchema(u, c, "ehr_lookups");
        // species and pedigree

        try
        {
            if (newAnimalData.getSpecies() == null)
                throw new ValidationException("Species is required");
            // species exists - make sure it is valid
            TableInfo ti = schema.getTable("CurrentSpeciesLookup", schema.getDefaultContainerFilter());
            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("SpeciesCode"), newAnimalData.getSpecies(), CompareType.EQUAL);
            TableSelector ts = new TableSelector(ti, filter, null);
            row = ts.getMap();
            if (row == null || !row.get("speciesCode").toString().equals(newAnimalData.getSpecies()))
                throw new ValidationException("Invalid Species code entered:" + newAnimalData.getSpecies());
            // Baboons require a pedigreee
            if (newAnimalData.getPedigree() == null && row.get("arcSpeciesCode").toString().equals("PC"))
                throw new ValidationException("Pedigree is required for baboons");
        }
        catch (Exception e)
        {
            throw new ValidationException(e.getMessage());

        }

        if (newAnimalData.getBirthCode() == null)
            throw new ValidationException("Birthdate status is required");

        // Acquisition Code-AcquisitionType
        try
        {
            if (newAnimalData.getAcquisitionType() == null)
                throw new ValidationException("Valid Acquisition code is required");

            TableInfo ti = schemaEHRLU.getTable("AcquisitionType", schema.getDefaultContainerFilter());
            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("value"), newAnimalData.getAcquisitionType().toString(), CompareType.EQUAL);
            TableSelector ts = new TableSelector(ti, filter, null);

            if (ts.getRowCount() != 1)
                throw new ValidationException("Acquisition code is required");
        }
        catch (Exception e)
        {
            throw new ValidationException(e.getMessage());
        }

        // bdstatus
        if (newAnimalData.getBirthCode() == null)
            throw new ValidationException("Birth code is required");

        // gender
        if (newAnimalData.getGender() == null)
            throw new ValidationException("Gender is required");

        // colony
        if (newAnimalData.getColony() == null)
            throw new ValidationException("Colony is required");

        // animalAccount - not required for offsite acquisitions
        try
        {
            if (newAnimalData.getAnimalAccount() == null && !offSiteAcqCodes.contains(newAnimalData.getAcquisitionType().toString()))
                throw new ValidationException("Animal Account is required");

            if (newAnimalData.getAnimalAccount() != null)
            {
                TableInfo ti = schema.getTable("ValidAccounts", schema.getDefaultContainerFilter());
                SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("account"), newAnimalData.getAnimalAccount(), CompareType.EQUAL);
                filter.addCondition(FieldKey.fromParts("date"), newAnimalData.getAcqDate(), CompareType.DATE_LTE);
                filter.addClause(new SimpleFilter.AndClause(
                        new CompareType.CompareClause(FieldKey.fromParts("enddate"), CompareType.ISBLANK, null)));

                TableSelector ts = new TableSelector(ti, filter, null);
                if (ts.getRowCount() != 1 || (newAnimalData.getAnimalAccount() == null))
                    throw new ValidationException("Valid Animal Account is required");
            }
        }
        catch (Exception e)
        {
            throw new ValidationException(e.getMessage());
        }

        // Valid Institutions
        try
        {
            // ownerInstitution
            if (newAnimalData.getOwnerInstitution() == null)
                throw new ValidationException("Owner Institution is required");
            //responsibleInstitution
            if (newAnimalData.getResponsibleInstitution() == null)
                throw new ValidationException("Responsible Institution is required");

            TableInfo ti = schema.getTable("validInstitutions", schema.getDefaultContainerFilter());
            SimpleFilter filterRI = new SimpleFilter(FieldKey.fromParts("institution_id"), newAnimalData.getResponsibleInstitution(), CompareType.EQUAL);

            TableSelector tsRI = new TableSelector(ti, filterRI, null);
            if (tsRI.getRowCount() != 1)
                throw new ValidationException("Responsible Institution is required");

            SimpleFilter filterOI = new SimpleFilter(FieldKey.fromParts("institution_id"), newAnimalData.getOwnerInstitution(), CompareType.EQUAL);

            TableSelector tsOI = new TableSelector(ti, filterOI, null);
            if (tsOI.getRowCount() != 1)
                throw new ValidationException("Responsible Institution is required");
        }
        catch (Exception e)
        {
            throw new ValidationException(e.getMessage());
        }

        // room
        if (newAnimalData.getRoom() == null)
            throw new ValidationException("Room is required");

        // diet
        if (newAnimalData.getDiet() == null)
            throw new ValidationException("Diet is required");

        // IACUC - not required for offsite acquisitions
        try
        {
            if (newAnimalData.getIacuc() == null && !offSiteAcqCodes.contains(newAnimalData.getAcquisitionType().toString()))
                throw new ValidationException("IACUC is required");
            if (newAnimalData.getIacuc() != null)
            {
                // Ensure initial IACUC was valid on animals arival date
                TableInfo ti = schemaEHR.getTable("ProtocolLookup", schema.getDefaultContainerFilter());
                SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("Iacuc"), newAnimalData.getIacuc(), CompareType.EQUAL);
                filter.addCondition(FieldKey.fromParts("ApprovalDate"), newAnimalData.getAcqDate(), CompareType.DATE_LTE);
                filter.addClause(new SimpleFilter.AndClause(
                        new CompareType.CompareClause(FieldKey.fromParts("EndDate"), CompareType.ISBLANK, null)));
                TableSelector ts = new TableSelector(ti, filter, null);
                if (ts.getRowCount() != 1)
                    throw new ValidationException("Valid IACUC is required");
            }
        }
        catch (Exception e)
        {
            throw new ValidationException(e.getMessage());
        }

        // NULLABLE fields
        // sire
        // dam
        // cage
        // SourceInstitutionLocation
    }
}
