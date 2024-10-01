package org.labkey.snprc_ehr.domain;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.json.JSONObject;
import org.labkey.api.collections.ArrayListMap;
import org.labkey.api.data.Container;
import org.labkey.api.security.User;
import org.labkey.api.util.DateUtil;
import org.labkey.snprc_ehr.SNPRC_EHRManager;

import java.text.ParseException;
import java.util.Date;
import java.util.Map;
import java.util.Objects;

public class NewAnimalData
{
    // title case used to maintain consistency with table column naming convention
    private String _id;
    private Date _birthDate;
    private Integer _birthCode;
    private Integer _acquisitionType;
    private Date _acqDate;
    private Integer _sourceInstitutionLocation;
    private String _gender;
    private String _sire;
    private String _dam;
    private String _species;
    private Integer _colony;
    private String _animalAccount;
    private Integer _ownerInstitution;
    private Integer _responsibleInstitution;
    private Integer _room;
    private Integer _cage;
    private Integer _diet;
    private Integer _pedigree;
    private String _iacuc;
    private Date _created;
    private Date _modified;
    private Integer _createdBy;
    private Integer _modifiedBy;
    private String _createdByName;
    private String _modifiedByName;
    private String _objectId;
    //private Integer _qcState;

    public static final String DATE_FORMAT = "yyyy-MM-dd";  //
    public static final String DATE_TIME_FORMAT = "yyyy-MM-dd'T'HH:mm:ss";  // ISO8601 w/24-hour time and 'T' character
    public static final String SQL_DATE_TIME_FORMAT = "yyyy-MM-dd HH:mm:ss:SSS";

    public static final String NEWANIMAL_ID = "Id";
    public static final String NEWANIMAL_BIRTH_DATE = "BirthDate";
    public static final String NEWANIMAL_BIRTH_CODE = "BirthCode";
    public static final String NEWANIMAL_ACQUISITION_TYPE = "AcquisitionType";
    public static final String NEWANIMAL_ACQ_DATE = "AcqDate";
    public static final String NEWANIMAL_GENDER = "Gender";
    public static final String NEWANIMAL_SIRE = "Sire";
    public static final String NEWANIMAL_DAM = "Dam";
    public static final String NEWANIMAL_SPECIES = "Species";
    public static final String NEWANIMAL_COLONY = "Colony";
    public static final String NEWANIMAL_ANIMAL_ACCOUNT = "AnimalAccount";
    public static final String NEWANIMAL_OWNER_INSTITUTION = "OwnerInstitution";
    public static final String NEWANIMAL_RESPONSIBLE_INSTITUTION = "ResponsibleInstitution";
    public static final String NEWANIMAL_ROOM = "Room";
    public static final String NEWANIMAL_CAGE = "Cage";
    public static final String NEWANIMAL_DIET = "Diet";
    public static final String NEWANIMAL_PEDIGREE = "Pedigree";
    public static final String NEWANIMAL_IACUC = "IACUC";
    public static final String NEWANIMAL_DATE_CREATED = "Created";
    public static final String NEWANIMAL_DATE_MODIFIED = "Modified";
    public static final String NEWANIMAL_CREATED_BY = "CreatedBy";
    public static final String NEWANIMAL_MODIFIED_BY = "ModifiedBy";
    public static final String NEWANIMAL_CREATED_BY_NAME = "CreatedByName";
    public static final String NEWANIMAL_MODIFIED_BY_NAME = "ModifiedByName";
    public static final String NEWANIMAL_OBJECTID = "ObjectId";
    public static final String NEWANIMAL_CONTAINER = "Container";
    public static final String NEWANIMAL_SOURCE_LOCATION = "SourceInstitutionLocation";
    //public static final String NEWANIMAL_QCSTATE = "QcState";


    public NewAnimalData()
    {

    }

    public NewAnimalData(Container c, User u, JSONObject json) throws RuntimeException
    {
        try
        {
            this.setId(json.has(NEWANIMAL_ID) && !json.isNull(NEWANIMAL_ID) ? json.getString(NEWANIMAL_ID) : null);
            this.setBirthCode(json.has(NEWANIMAL_BIRTH_CODE) && !json.isNull(NEWANIMAL_BIRTH_CODE) ? json.getInt(NEWANIMAL_BIRTH_CODE) : null);
            this.setAcquisitionType(json.has(NEWANIMAL_ACQUISITION_TYPE) && !json.isNull(NEWANIMAL_ACQUISITION_TYPE) ? json.getInt(NEWANIMAL_ACQUISITION_TYPE) : null);
            this.setGender(json.has(NEWANIMAL_GENDER) && !json.isNull(NEWANIMAL_GENDER) ? json.getString(NEWANIMAL_GENDER) : null);
            this.setSire(json.has(NEWANIMAL_SIRE) && !json.isNull(NEWANIMAL_SIRE) ? json.getString(NEWANIMAL_SIRE) : null);
            this.setDam(json.has(NEWANIMAL_DAM) && !json.isNull(NEWANIMAL_DAM) ? json.getString(NEWANIMAL_DAM) : null);
            this.setSpecies(json.has(NEWANIMAL_SPECIES) && !json.isNull(NEWANIMAL_SPECIES) ? json.getString(NEWANIMAL_SPECIES) : null);
            this.setColony(json.has(NEWANIMAL_COLONY) && !json.isNull(NEWANIMAL_COLONY) ? json.getInt(NEWANIMAL_COLONY) : null);
            this.setAnimalAccount(json.has(NEWANIMAL_ANIMAL_ACCOUNT) && !json.isNull(NEWANIMAL_ANIMAL_ACCOUNT) ? json.getString(NEWANIMAL_ANIMAL_ACCOUNT) : null);
            this.setOwnerInstitution(json.has(NEWANIMAL_OWNER_INSTITUTION) && !json.isNull(NEWANIMAL_OWNER_INSTITUTION) ? json.getInt(NEWANIMAL_OWNER_INSTITUTION) : null);
            this.setOwnerInstitution(json.has(NEWANIMAL_RESPONSIBLE_INSTITUTION) && !json.isNull(NEWANIMAL_RESPONSIBLE_INSTITUTION) ? json.getInt(NEWANIMAL_RESPONSIBLE_INSTITUTION) : null);
            this.setRoom(json.has(NEWANIMAL_ROOM) && !json.isNull(NEWANIMAL_ROOM) ? json.getInt(NEWANIMAL_ROOM) : null);
            this.setCage(json.has(NEWANIMAL_CAGE) && !json.isNull(NEWANIMAL_CAGE) ? json.getInt(NEWANIMAL_CAGE) : null);
            this.setDiet(json.has(NEWANIMAL_DIET) && !json.isNull(NEWANIMAL_DIET) ? json.getInt(NEWANIMAL_DIET) : null);
            this.setPedigree(json.has(NEWANIMAL_PEDIGREE) && !json.isNull(NEWANIMAL_PEDIGREE) ? json.getInt(NEWANIMAL_PEDIGREE) : null);
            this.setIacuc(json.has(NEWANIMAL_IACUC) && !json.isNull(NEWANIMAL_IACUC) ? json.getString(NEWANIMAL_IACUC) : null);
            this.setObjectId(json.has(NEWANIMAL_OBJECTID) && !json.isNull(NEWANIMAL_OBJECTID) ? json.getString(NEWANIMAL_OBJECTID) : null);
            this.setCreatedBy(c, u, json.has(NEWANIMAL_CREATED_BY) && !json.isNull(NEWANIMAL_CREATED_BY) ? json.getInt(NEWANIMAL_CREATED_BY) : null);
            this.setModifiedBy(c, u, json.has(NEWANIMAL_MODIFIED_BY) && !json.isNull(NEWANIMAL_MODIFIED_BY) ? json.getInt(NEWANIMAL_MODIFIED_BY) : null);
            this.setCreatedByName(json.has(NEWANIMAL_CREATED_BY_NAME) && !json.isNull(NEWANIMAL_CREATED_BY_NAME) ? json.getString(NEWANIMAL_CREATED_BY_NAME) : null);
            this.setModifiedByName(json.has(NEWANIMAL_MODIFIED_BY_NAME) && !json.isNull(NEWANIMAL_MODIFIED_BY_NAME) ? json.getString(NEWANIMAL_MODIFIED_BY_NAME) : null);
            this.setSourceInstitutionLocation(json.has(NEWANIMAL_SOURCE_LOCATION) && !json.isNull(NEWANIMAL_SOURCE_LOCATION) ? json.getInt(NEWANIMAL_SOURCE_LOCATION) : null);
            //this.setQcState(json.has(NEWANIMAL_QCSTATE) && !json.isNull(NEWANIMAL_QCSTATE) ? json.getInt(NEWANIMAL_QCSTATE) : null);

            String birthDateString = json.has(NEWANIMAL_BIRTH_DATE) && !json.isNull(NEWANIMAL_BIRTH_DATE) ? json.getString(NEWANIMAL_BIRTH_DATE) : null;
            String acqDateString = json.has(NEWANIMAL_ACQ_DATE) && !json.isNull(NEWANIMAL_ACQ_DATE) ? json.getString(NEWANIMAL_ACQ_DATE) : null;
            String createdDateString = json.has(NEWANIMAL_DATE_CREATED) && !json.isNull(NEWANIMAL_DATE_CREATED) ? json.getString(NEWANIMAL_DATE_CREATED) : null;
            String modifiedDateString = json.has(NEWANIMAL_DATE_MODIFIED) && !json.isNull(NEWANIMAL_DATE_MODIFIED) ? json.getString(NEWANIMAL_DATE_MODIFIED) : null;

            try
            {
                this.setBirthDate(birthDateString == null ? new Date() : DateUtil.parseDateTime(birthDateString, DATE_FORMAT));
                this.setAcqDate(acqDateString == null ? null : DateUtil.parseDateTime(acqDateString, DATE_FORMAT));
                this.setCreated(createdDateString == null ? new Date() : DateUtil.parseDateTime(createdDateString, DATE_FORMAT));
                this.setModified(modifiedDateString == null ? new Date() : DateUtil.parseDateTime(modifiedDateString, DATE_FORMAT));
            }
            catch (ParseException e)
            {
                throw new RuntimeException(e.getMessage());
            }

        }
        catch (Exception e)
        {
            throw new RuntimeException(e.getMessage());
        }

    }

    @NotNull
    public Map<String, Object> toMap(Container c, User u)
    {
        Map<String, Object> values = new ArrayListMap<>();

        values.put(NEWANIMAL_ID, getId());
        values.put(NEWANIMAL_BIRTH_DATE, getBirthDate());
        values.put(NEWANIMAL_BIRTH_CODE, getBirthCode());
        values.put(NEWANIMAL_ACQUISITION_TYPE, getAcquisitionType());
        values.put(NEWANIMAL_ACQ_DATE, getAcqDate());
        values.put(NEWANIMAL_GENDER, getGender());
        values.put(NEWANIMAL_SIRE, getSire());
        values.put(NEWANIMAL_DAM, getDam());
        values.put(NEWANIMAL_SPECIES, getSpecies());
        values.put(NEWANIMAL_COLONY, getColony());
        values.put(NEWANIMAL_ANIMAL_ACCOUNT, getAnimalAccount());
        values.put(NEWANIMAL_OWNER_INSTITUTION, getOwnerInstitution());
        values.put(NEWANIMAL_RESPONSIBLE_INSTITUTION, getResponsibleInstitution());
        values.put(NEWANIMAL_ROOM, getRoom());
        values.put(NEWANIMAL_CAGE, getCage());
        values.put(NEWANIMAL_DIET, getDiet());
        values.put(NEWANIMAL_PEDIGREE, getPedigree());
        values.put(NEWANIMAL_IACUC, getIacuc());
        values.put(NEWANIMAL_OBJECTID, getObjectId());
        values.put(NEWANIMAL_CREATED_BY, getCreatedBy());
        values.put(NEWANIMAL_MODIFIED_BY, getModifiedBy());
        values.put(NEWANIMAL_CREATED_BY_NAME, getCreatedByName());
        values.put(NEWANIMAL_MODIFIED_BY_NAME, getModifiedByName());
        values.put(NEWANIMAL_DATE_CREATED, getCreated());
        values.put(NEWANIMAL_DATE_MODIFIED, getModified());
        values.put(NEWANIMAL_CONTAINER, c.getId());
        values.put(NEWANIMAL_SOURCE_LOCATION, getSourceInstitutionLocation());

        return values;
    }

    @NotNull
    public JSONObject toJSON(Container c, User u)
    {
        JSONObject json = new JSONObject();

        if (getId() != null)
            json.put(NEWANIMAL_ID, getId());
        if (getBirthDate() != null)
            json.put(NEWANIMAL_BIRTH_DATE, getBirthDate());
        json.put(NEWANIMAL_BIRTH_CODE, getBirthCode());
        json.put(NEWANIMAL_ACQUISITION_TYPE, getAcquisitionType());
        json.put(NEWANIMAL_ACQ_DATE, getAcqDate());
        json.put(NEWANIMAL_GENDER, getGender());
        if (getSire() != null)
            json.put(NEWANIMAL_SIRE, getSire());
        if (getDam() != null)
            json.put(NEWANIMAL_DAM, getDam());
        json.put(NEWANIMAL_SPECIES, getSpecies());
        json.put(NEWANIMAL_COLONY, getColony());
        json.put(NEWANIMAL_ANIMAL_ACCOUNT, getAnimalAccount());
        json.put(NEWANIMAL_OWNER_INSTITUTION, getOwnerInstitution());
        json.put(NEWANIMAL_RESPONSIBLE_INSTITUTION, getResponsibleInstitution());
        json.put(NEWANIMAL_ROOM, getRoom());
        if (getCage() != null)
            json.put(NEWANIMAL_CAGE, getCage());
        json.put(NEWANIMAL_DIET, getDiet());
        json.put(NEWANIMAL_PEDIGREE, getPedigree());
        json.put(NEWANIMAL_IACUC, getIacuc());
        if (getObjectId() != null)
            json.put(NEWANIMAL_OBJECTID, getObjectId());
        json.put(NEWANIMAL_CREATED_BY, getCreatedBy());
        json.put(NEWANIMAL_MODIFIED_BY, getModifiedBy());
        json.put(NEWANIMAL_CREATED_BY_NAME, getCreatedByName());
        json.put(NEWANIMAL_MODIFIED_BY_NAME, getModifiedByName());
        json.put(NEWANIMAL_DATE_CREATED, getCreated());
        json.put(NEWANIMAL_DATE_MODIFIED, getModified());
        json.put(NEWANIMAL_CONTAINER, c.getId());
        if (getSourceInstitutionLocation() != null)
            json.put(NEWANIMAL_SOURCE_LOCATION, getSourceInstitutionLocation());

        return json;
    }


    @Nullable
    public String birthDateToString()
    {
        return DateUtil.formatIsoDate(getBirthDate());
    }

    @Nullable
    public String acqDateToString()
    {
        return DateUtil.formatIsoDate(getAcqDate());
    }

    @Nullable
    public String modifiedDateToString()
    {
        return DateUtil.formatIsoDate(getModified());
    }

    @Nullable
    public String createdDateToString()
    {
        return DateUtil.formatIsoDate(getCreated());
    }

    public String getId()
    {
        return _id;
    }

    public void setId(String id)
    {
        _id = id;
    }

    public Date getBirthDate()
    {
        return _birthDate;
    }

    public void setBirthDate(Date birthDate)
    {
        _birthDate = birthDate;
    }

    public Integer getBirthCode()
    {
        return _birthCode;
    }

    public void setBirthCode(Integer birthCode)
    {
        _birthCode = birthCode;
    }

    public Integer getAcquisitionType()
    {
        return _acquisitionType;
    }

    public void setAcquisitionType(Integer acquisitionType)
    {
        _acquisitionType = acquisitionType;
    }

    public Date getAcqDate()
    {
        return _acqDate;
    }

    public void setAcqDate(Date acqDate)
    {
        _acqDate = acqDate;
    }

    public String getGender()
    {
        return _gender;
    }

    public void setGender(String gender)
    {
        _gender = gender;
    }

    public String getSire()
    {
        return _sire;
    }

    public void setSire(String sire)
    {
        _sire = sire;
    }

    public String getDam()
    {
        return _dam;
    }

    public void setDam(String dam)
    {
        _dam = dam;
    }

    public String getSpecies()
    {
        return _species;
    }

    public void setSpecies(String species)
    {
        _species = species;
    }

    public Integer getColony()
    {
        return _colony;
    }

    public void setColony(Integer colony)
    {
        _colony = colony;
    }

    public String getAnimalAccount()
    {
        return _animalAccount;
    }

    public void setAnimalAccount(String animalAccount)
    {
        _animalAccount = animalAccount;
    }

    public Integer getOwnerInstitution()
    {
        return _ownerInstitution;
    }

    public void setOwnerInstitution(Integer ownerInstitution)
    {
        _ownerInstitution = ownerInstitution;
    }

    public Integer getResponsibleInstitution()
    {
        return _responsibleInstitution;
    }

    public void setResponsibleInstitution(Integer responsibleInstitution)
    {
        _responsibleInstitution = responsibleInstitution;
    }

    public Integer getRoom()
    {
        return _room;
    }

    public void setRoom(Integer room)
    {
        _room = room;
    }

    public Integer getCage()
    {
        return _cage;
    }

    public void setCage(Integer cage)
    {
        _cage = cage;
    }

    public Integer getDiet()
    {
        return _diet;
    }

    public void setDiet(Integer diet)
    {
        _diet = diet;
    }

    public Integer getPedigree()
    {
        return _pedigree;
    }

    public void setPedigree(Integer pedigree)
    {
        _pedigree = pedigree;
    }

    public String getIacuc()
    {
        return _iacuc;
    }

    public void setIacuc(String iacuc)
    {
        _iacuc = iacuc;
    }

    public Date getCreated()
    {
        return _created;
    }

    public void setCreated(Date created)
    {
        _created = created;
    }

    public Date getModified()
    {
        return _modified;
    }

    public void setModified(Date modified)
    {
        _modified = modified;
    }

    public void setCreatedBy(Container c, User u, Integer createdBy)
    {
        _createdBy = createdBy;
        if (_createdBy != null)
        {
            _createdByName = SNPRC_EHRManager.getUserDisplayName(_createdBy);
        }
        else
        {
            _createdByName = null;
        }

    }

    public Integer getCreatedBy()
    {
        return _createdBy;
    }

    public void setModifiedBy(Container c, User u, Integer modifiedBy)
    {
        _modifiedBy = modifiedBy;
        if (_modifiedBy != null)
        {
            _modifiedByName = SNPRC_EHRManager.getUserDisplayName(_modifiedBy);
        }
        else
        {
            _modifiedByName = null;
        }
    }

    public void setCreatedBy(Integer createdBy)
    {
        _createdBy = createdBy;
    }

    public Integer getModifiedBy()
    {
        return _modifiedBy;
    }

    public void setModifiedBy(Integer modifiedBy)
    {
        _modifiedBy = modifiedBy;
    }

    public String getCreatedByName()
    {
        return _createdByName;
    }

    public void setCreatedByName(String createdByName)
    {
        _createdByName = createdByName;
    }

    public String getModifiedByName()
    {
        return _modifiedByName;
    }

    public void setModifiedByName(String modifiedByName)
    {
        _modifiedByName = modifiedByName;
    }

    public String getObjectId()
    {
        return _objectId;
    }

    public void setObjectId(String objectId)
    {
        _objectId = objectId;
    }

    public Integer getSourceInstitutionLocation()
    {
        return _sourceInstitutionLocation;
    }

    public void setSourceInstitutionLocation(Integer sourceInstitutionLocation)
    {
        _sourceInstitutionLocation = sourceInstitutionLocation;
    }

    @Override
    public boolean equals(Object o)
    {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        NewAnimalData that = (NewAnimalData) o;
        return _id.equals(that._id) && _birthDate.equals(that._birthDate) && _birthCode.equals(that._birthCode) && _acquisitionType.equals(that._acquisitionType) && _acqDate.equals(that._acqDate) && Objects.equals(_sourceInstitutionLocation, that._sourceInstitutionLocation) && _gender.equals(that._gender) && Objects.equals(_sire, that._sire) && Objects.equals(_dam, that._dam) && _species.equals(that._species) && _colony.equals(that._colony) && Objects.equals(_animalAccount, that._animalAccount) && _ownerInstitution.equals(that._ownerInstitution) && _responsibleInstitution.equals(that._responsibleInstitution) && _room.equals(that._room) && Objects.equals(_cage, that._cage) && _diet.equals(that._diet) && Objects.equals(_pedigree, that._pedigree) && Objects.equals(_iacuc, that._iacuc) && Objects.equals(_created, that._created) && Objects.equals(_modified, that._modified) && Objects.equals(_createdBy, that._createdBy) && Objects.equals(_modifiedBy, that._modifiedBy) && Objects.equals(_createdByName, that._createdByName) && Objects.equals(_modifiedByName, that._modifiedByName) && Objects.equals(_objectId, that._objectId);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(_id, _birthDate, _birthCode, _acquisitionType, _acqDate, _sourceInstitutionLocation, _gender, _sire, _dam, _species, _colony, _animalAccount, _ownerInstitution, _responsibleInstitution, _room, _cage, _diet, _pedigree, _iacuc, _created, _modified, _createdBy, _modifiedBy, _createdByName, _modifiedByName, _objectId);
    }
}
