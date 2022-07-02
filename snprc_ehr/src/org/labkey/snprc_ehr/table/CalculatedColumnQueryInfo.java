package org.labkey.snprc_ehr.table;

import lombok.Data;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.query.UserSchema;

import java.util.List;

@Data
public class CalculatedColumnQueryInfo implements QueryInfo
{
    private AbstractTableInfo tableInfo;

    private ColumnInfo primaryKeyColumn;

    private ColumnInfo idColumn;

    private UserSchema ehrSchema;

    private String query;

    private String label;

    private List<CalculatedColumn> calculatedColumns;

}
