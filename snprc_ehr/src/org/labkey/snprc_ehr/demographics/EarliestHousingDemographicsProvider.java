package org.labkey.snprc_ehr.demographics;

import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

public class EarliestHousingDemographicsProvider extends AbstractListDemographicsProvider

{

    public EarliestHousingDemographicsProvider(Module owner)
    {
        super(owner, "study", "demographicsEarliestHousing", "earliestHousing");
        _supportsQCState = false;
    }

    @Override
    public String getName()
    {
        return "Earliest Housing";
    }

    @Override
    protected Collection<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("FirstHousingDate"));
        keys.add(FieldKey.fromString("FirstHousingRoom"));
        keys.add(FieldKey.fromString("FirstHousingRoomDescription"));

        return keys;
    }

    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return ("study".equalsIgnoreCase(schema) && "Housing".equalsIgnoreCase(query));
    }
}
