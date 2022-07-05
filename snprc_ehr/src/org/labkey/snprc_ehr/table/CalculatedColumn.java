package org.labkey.snprc_ehr.table;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

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

    private boolean isHidden;

}
