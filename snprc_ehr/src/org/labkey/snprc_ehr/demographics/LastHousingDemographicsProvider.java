package org.labkey.snprc_ehr.demographics;

import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

/**
 * User: bimber
 * Date: 7/9/13
 * Time: 10:12 PM
 */
public class LastHousingDemographicsProvider extends AbstractListDemographicsProvider  // using list demographics provider because keys clash with existing keys otherwise
{
    public LastHousingDemographicsProvider(Module owner)
    {
        super(owner, "study", "demographicsLastHousing", "lastHousing");
        _supportsQCState = false;
    }

    @Override
    public String getName()
    {
        return "Last Housing";
    }

    @Override
    protected Collection<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("Location"));
        keys.add(FieldKey.fromString("area"));
        keys.add(FieldKey.fromString("room"));
        keys.add(FieldKey.fromString("cage"));
        keys.add(FieldKey.fromString("date"));
        keys.add(FieldKey.fromString("enddate"));

        return keys;
    }

    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return ("study".equalsIgnoreCase(schema) && "Housing".equalsIgnoreCase(query));
    }
}
