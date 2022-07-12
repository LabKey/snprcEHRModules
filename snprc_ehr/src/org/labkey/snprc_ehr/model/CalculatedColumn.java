package org.labkey.snprc_ehr.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import org.apache.commons.text.CaseUtils;

/**
 * Object containing Column information for data that will be calculated via SQL query
 * and added as a column to a table
 */
@Getter
@Setter
@AllArgsConstructor
public class CalculatedColumn
{

    private String columnName;

    private String label;

    private String lookupTableName;

    private String lookupTableKeyName;

    private String lookupUrl;

    private boolean isHidden;

    public CalculatedColumn(String label) {
        this.label = label;
        this.columnName = CaseUtils.toCamelCase(label, false);
        this.isHidden = false;
    }

    public CalculatedColumn(String label, boolean isHidden) {
        this.label = label;
        this.columnName = CaseUtils.toCamelCase(label, false);
        this.isHidden = isHidden;
    }

    public CalculatedColumn(String label, String lookupTableName, String lookupTableKeyName, String lookupUrl) {
        this.label = label;
        this.columnName = CaseUtils.toCamelCase(label, false);
        this.lookupTableName = lookupTableName;
        this.lookupTableKeyName = lookupTableKeyName;
        this.lookupUrl = lookupUrl;
        this.isHidden = false;
    }

    public CalculatedColumn(String label, String lookupTableName, String lookupTableKeyName, String lookupUrl, boolean isHidden) {
        this.label = label;
        this.columnName = CaseUtils.toCamelCase(label, false);
        this.lookupTableName = lookupTableName;
        this.lookupTableKeyName = lookupTableKeyName;
        this.lookupUrl = lookupUrl;
        this.isHidden = isHidden;
    }


}
