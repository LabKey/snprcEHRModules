
package org.labkey.snprc_ehr.demographics;


import org.labkey.api.data.CompareType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;


public class MhcSummaryDemographicsProvider extends AbstractListDemographicsProvider
{
    public MhcSummaryDemographicsProvider(Module module)
    {
        super(module, "study", "mhcSummary", "mhcSummary");
    }

    protected Set<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("mhcSummary"));

        return keys;
    }

    @Override
    protected SimpleFilter getFilter(Collection<String> ids)
    {
        SimpleFilter filter = super.getFilter(ids);
        filter.addCondition(FieldKey.fromString("publicData"), true, CompareType.EQUAL);

        return filter;
    }

    @Override
    public Collection<String> getKeysToTest()
    {
        //for now, simply skip the whole provider.  because different records can be active from day to day, this makes validation tricky
        Set<String> keys = new HashSet<>(super.getKeysToTest());
        keys.remove(_propName);

        return keys;
    }
}
