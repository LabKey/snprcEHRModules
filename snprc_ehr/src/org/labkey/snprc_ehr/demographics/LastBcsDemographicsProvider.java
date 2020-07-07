package org.labkey.snprc_ehr.demographics;


import org.labkey.api.data.CompareType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

/**
 * Created by thawkins on 7/6/2020.
 */

public class LastBcsDemographicsProvider extends AbstractListDemographicsProvider
{

    public LastBcsDemographicsProvider(Module owner)
    {
        super(owner, "study", "demographicsLastBCS", "LastBCS");
        _supportsQCState = false;
    }

    @Override
    protected Set<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("BcsDate"));
        keys.add(FieldKey.fromString("LastBCS"));

        return keys;
    }

    @Override
    protected Sort getSort()
    {
        return new Sort("-Id");
    }

    @Override
    protected SimpleFilter getFilter(Collection<String> ids)
    {
        SimpleFilter filter = super.getFilter(ids);
        filter.addCondition(FieldKey.fromString("qcstate/publicData"), true, CompareType.EQUAL);

        return filter;
    }
}
