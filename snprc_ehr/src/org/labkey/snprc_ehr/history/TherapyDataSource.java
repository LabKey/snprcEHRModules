package org.labkey.snprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.util.Formats;
import java.sql.SQLException;
import java.text.DecimalFormat;

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
        addFloatField(rs, sb, "concentration", "Drug Conc", "conc_units");
        addFloatField(rs, sb, "dosage", "Dosage", "dosage_units");
        addFloatField(rs, sb, "volume", "Volume", "vol_units");
        addFloatField(rs, sb, "amount", "Amount", "amount_units");
        addStringField(rs, sb, "performedby", "Ordered By");
        addStringField(rs, sb, "remark", "Remark");
        addStringField(rs, sb, "description", "Description");
        addBooleanField(rs, sb, "isActive", "Is Active");
        addBooleanField(rs, sb, "isExpired", "Is Expired");

        return sb.toString();
    }

    private void addStringField(Results rs, StringBuilder sb, String columnName, String displayLabel) throws SQLException
    {
        if (isFieldPopulated(rs, columnName))
        {
            addField(sb, displayLabel, "", rs.getString(new FieldKey(null,columnName)));
        }
    }

    private void addStringFieldLookup(Results rs, StringBuilder sb, String columnName, String parentColumnName, String displayLabel) throws SQLException
    {
        FieldKey fieldKey = FieldKey.fromParts(parentColumnName, columnName);
        if( rs.hasColumn(fieldKey) && rs.getObject(fieldKey) != null)
        {
            addField(sb, displayLabel, "", rs.getString(fieldKey));
        }
    }

    private void addBooleanField(Results rs, StringBuilder sb, String columnName, String displayLabel) throws SQLException
    {
        if (isFieldPopulated(rs, columnName))
        {
            addField(sb, displayLabel, "", String.valueOf(rs.getBoolean(new FieldKey(null,columnName))));
        }
    }

    private void addIntegerField(Results rs, StringBuilder sb, String columnName, String displayLabel) throws SQLException
    {
        if (isFieldPopulated(rs, columnName))
        {
            addField(sb, displayLabel, "", String.valueOf(rs.getInt(new FieldKey(null,columnName))));
        }
    }
    private void addFloatField(Results rs, StringBuilder sb, String columnName, String displayLabel, String unitsColumnName) throws SQLException
    {
        if (isFieldPopulated(rs, columnName))
        {
            DecimalFormat decimalFormat = Formats.fv3;
            String  units = rs.getString(new FieldKey(null,unitsColumnName));

            addField(sb, displayLabel, units, decimalFormat.format(rs.getFloat(new FieldKey(null,columnName))));
        }
    }

    private void addField(StringBuilder sb, String displayLabel, String suffix, String value)
    {
        sb.append(displayLabel);
        sb.append(": ");
        sb.append(value);
        sb.append(" ").append(suffix);
        sb.append("\n");
    }

    private boolean isFieldPopulated(Results rs, String columnName) throws SQLException
    {
        return rs.hasColumn(FieldKey.fromString(columnName)) && rs.getObject(new FieldKey(null,columnName)) != null;
    }
}
