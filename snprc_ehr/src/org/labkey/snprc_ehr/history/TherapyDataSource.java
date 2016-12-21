package org.labkey.snprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;

import java.sql.SQLException;

public class TherapyDataSource extends AbstractDataSource
{
    public TherapyDataSource(Module module)
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
