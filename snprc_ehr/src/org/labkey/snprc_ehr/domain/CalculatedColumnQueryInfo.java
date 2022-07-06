package org.labkey.snprc_ehr.domain;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.query.UserSchema;
import org.labkey.snprc_ehr.domain.CalculatedColumn;

import java.util.List;

/**
 * Object containing query info for data to be calculated via SQL query amd added as a column to a table
 */
@Getter
@Setter
@NoArgsConstructor
public class CalculatedColumnQueryInfo
{
    private AbstractTableInfo tableInfo;

    private ColumnInfo primaryKeyColumn;

    private ColumnInfo idColumn;

    private UserSchema ehrSchema;

    private String query;

    private String label;

    private List<CalculatedColumn> calculatedColumns;

}
