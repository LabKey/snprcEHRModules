package org.labkey.snprc_ehr.audit;

import org.labkey.api.audit.AbstractAuditTypeProvider;
import org.labkey.api.audit.AuditTypeEvent;
import org.labkey.api.audit.AuditTypeProvider;
import org.labkey.api.audit.DetailedAuditTypeEvent;
import org.labkey.api.audit.query.AbstractAuditDomainKind;
import org.labkey.api.audit.query.DefaultAuditTypeTable;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.PropertyStorageSpec;
import org.labkey.api.data.TableInfo;
import org.labkey.api.exp.PropertyDescriptor;
import org.labkey.api.exp.PropertyType;
import org.labkey.api.exp.property.Domain;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.UserSchema;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;


public class BiocontainmentObservationsAuditProvider extends AbstractAuditTypeProvider implements AuditTypeProvider
{
    public static final String BIOCONTAINMENT_OBSERVATIONS_AUDIT_EVENT = "BiocontainmentObservationsAuditEvent";

    public static final String COLUMN_NAME_DATASET_ID = "DatasetId";
    public static final String COLUMN_NAME_HAS_DETAILS = "HasDetails";
    public static final String COLUMN_NAME_LSID = "Lsid";

    static final List<FieldKey> defaultVisibleColumns = new ArrayList<>();

    static
    {
        defaultVisibleColumns.add(FieldKey.fromParts(COLUMN_NAME_CREATED));
        defaultVisibleColumns.add(FieldKey.fromParts(COLUMN_NAME_CREATED_BY));
        defaultVisibleColumns.add(FieldKey.fromParts(COLUMN_NAME_CONTAINER));
        defaultVisibleColumns.add(FieldKey.fromParts(COLUMN_NAME_DATASET_ID));
        defaultVisibleColumns.add(FieldKey.fromParts(COLUMN_NAME_COMMENT));
    }

    public BiocontainmentObservationsAuditProvider()
    {
        super(new BiocontainmentObservationsAuditDomainKind());
    }

    @Override
    public String getEventName()
    {
        return BIOCONTAINMENT_OBSERVATIONS_AUDIT_EVENT;
    }

    @Override
    public String getLabel()
    {
        return "Biocontainment Observations events";
    }

    @Override
    public String getDescription()
    {
        return "Data about Biocontainment Observations dataset creation, deletion, and modification";
    }

    @Override
    public List<FieldKey> getDefaultVisibleColumns()
    {
        return defaultVisibleColumns;
    }

    @Override
    public TableInfo createTableInfo(UserSchema userSchema, ContainerFilter cf)
    {
        DefaultAuditTypeTable table = new DefaultAuditTypeTable(this, createStorageTableInfo(), userSchema, cf, defaultVisibleColumns);
        appendValueMapColumns(table, null, true);
        return table;
    }

    @Override
    public <K extends AuditTypeEvent> Class<K> getEventClass()
    {
        return (Class<K>) AuditEvent.class;
    }

    public static class AuditEvent extends DetailedAuditTypeEvent
    {
        private int _datasetId;
        private boolean _hasDetails;
        private String _lsid;

        /** Important for reflection-based instantiation */
        @SuppressWarnings("unused")
        public AuditEvent() {}

        public AuditEvent(Container container, String comment, int datasetId)
        {
            super(BIOCONTAINMENT_OBSERVATIONS_AUDIT_EVENT, container, comment);
            setDatasetId(datasetId);
        }

        public int getDatasetId()
        {
            return _datasetId;
        }

        public void setDatasetId(int datasetId)
        {
            _datasetId = datasetId;
        }

        public boolean isHasDetails()
        {
            return _hasDetails;
        }

        public void setHasDetails(boolean hasDetails)
        {
            _hasDetails = hasDetails;
        }

        public String getLsid()
        {
            return _lsid;
        }

        public void setLsid(String lsid)
        {
            _lsid = lsid;
        }

        @Override
        public Map<String, Object> getAuditLogMessageElements()
        {
            Map<String, Object> elements = new LinkedHashMap<>();
            elements.put("datasetId", getDatasetId());
            elements.put("hasDetails", isHasDetails());
            elements.put("lsid", getLsid());
            elements.putAll(super.getAuditLogMessageElements());
            return elements;
        }
    }

    public static class BiocontainmentObservationsAuditDomainKind extends AbstractAuditDomainKind
    {
        public static final String NAME = "BiocontainmentObservationsAuditDomain";
        public static final String NAMESPACE_PREFIX = "Audit-" + NAME;

        private static Set<PropertyDescriptor> _fields;

        public BiocontainmentObservationsAuditDomainKind()
        {
            super(BIOCONTAINMENT_OBSERVATIONS_AUDIT_EVENT);

            Set<PropertyDescriptor> fields = new LinkedHashSet<>();
            fields.add(createPropertyDescriptor(COLUMN_NAME_DATASET_ID, PropertyType.INTEGER));
            fields.add(createPropertyDescriptor(COLUMN_NAME_HAS_DETAILS, PropertyType.BOOLEAN));
            fields.add(createPropertyDescriptor(COLUMN_NAME_LSID, PropertyType.STRING, 300));
            fields.add(createOldDataMapPropertyDescriptor());
            fields.add(createNewDataMapPropertyDescriptor());
            _fields = Collections.unmodifiableSet(fields);
        }

        @Override
        public Set<PropertyDescriptor> getProperties()
        {
            return _fields;
        }

        @Override
        protected String getNamespacePrefix()
        {
            return NAMESPACE_PREFIX;
        }

        @Override
        public String getKindName()
        {
            return NAME;
        }

        @Override
        public Set<PropertyStorageSpec.Index> getPropertyIndices(Domain domain)
        {
            Set<PropertyStorageSpec.Index> indexes = super.getPropertyIndices(domain);
            indexes.add(new PropertyStorageSpec.Index(false, COLUMN_NAME_LSID));
            return indexes;
        }
    }
}
