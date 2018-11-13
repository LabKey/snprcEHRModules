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
public class ParentsDemographicsProvider extends AbstractListDemographicsProvider
{
    public ParentsDemographicsProvider(Module module)
    {
        super(module, "study", "parentageSummary", "parents");
        _supportsQCState = false;
    }

    protected Collection<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<>();
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("date"));
        keys.add(FieldKey.fromString("parent"));
        keys.add(FieldKey.fromString("relationship"));
        keys.add(FieldKey.fromString("method"));

        return keys;
    }

    @Override
    public boolean requiresRecalc(String schema, String query)
    {
        return ("study".equalsIgnoreCase(schema) && "Parentage".equalsIgnoreCase(query)) ||
                ("study".equalsIgnoreCase(schema) && "Birth".equalsIgnoreCase(query)) ||
                ("study".equalsIgnoreCase(schema) && "Demographics".equalsIgnoreCase(query));
    }

}
