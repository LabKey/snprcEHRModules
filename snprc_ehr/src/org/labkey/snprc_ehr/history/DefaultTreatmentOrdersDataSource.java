/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
package org.labkey.snprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;

import java.sql.SQLException;

public class DefaultTreatmentOrdersDataSource extends AbstractDataSource
{
    public DefaultTreatmentOrdersDataSource(Module module)
    {
        super("study", "Treatment Orders", "Therapy", "Therapy", module);
        setShowTime(true);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();

        addStringField(rs, sb, "enddate", "End Date");
        addStringField(rs, sb, "category", "Category");
        addStringField(rs, sb, "meaning", "Short Name");
        addStringFieldLookup(rs, sb,"meaning", "code","Treatment");
        addStringField(rs, sb, "qualifier", "Qualifier");
        addIntegerField(rs, sb, "frequency", "Frequency");
        addStringField(rs, sb, "route", "Route");
        addFloatWithUnitsColField(rs, sb, "concentration", "Drug Conc", "conc_units");
        addFloatWithUnitsColField(rs, sb, "dosage", "Dosage", "dosage_units");
        addFloatWithUnitsColField(rs, sb, "volume", "Volume", "vol_units");
        addFloatWithUnitsColField(rs, sb, "amount", "Amount", "amount_units");
        addStringField(rs, sb, "performedby", "Ordered By");
        addStringField(rs, sb, "remark", "Remark");
        addStringField(rs, sb, "description", "Description");

        return sb.toString();
    }


}
