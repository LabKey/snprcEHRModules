package org.labkey.snprc_ehr.table;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class CalculatedColumn
{

    private String columnName;

    private String label;

    private boolean isHidden;

}
