/*
 * Copyright (c) 2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.snprc_ehr.demographics;

import org.labkey.api.data.Sort;
import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;

import java.util.HashSet;
import java.util.Set;

/**
 * Created by thawkins on 8/9/2016.
 */
public class CurrentPedigreeDemographicsProvider extends AbstractListDemographicsProvider


{

    public CurrentPedigreeDemographicsProvider(Module owner)
    {
        super(owner, "study", "demographicsCurrentPedigree", "currentPedigree");
        _supportsQCState = false;
    }

    @Override
    protected Set<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("lsid"));
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("date"));
        keys.add(FieldKey.fromString("pedigree"));

        return keys;
    }


    @Override
    protected Sort getSort()
    {
        return new Sort("-date");
    }

    // Required to ensure cache stays in sync
    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return schema.equalsIgnoreCase("study") && query.equalsIgnoreCase("animal_group_members");
    }

    /*
    @Override
    protected SimpleFilter getFilter(Collection<String> ids)
    {
        SimpleFilter filter = super.getFilter(ids);
        filter.addCondition(FieldKey.fromString("isActive"), true, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("qcstate/publicData"), true, CompareType.EQUAL);

        return filter;
    }
    */
}
