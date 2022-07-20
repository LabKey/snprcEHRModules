package org.labkey.snprc_ehr.query;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.BaseColumnInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ldk.table.AbstractTableCustomizer;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.LookupForeignKey;
import org.labkey.api.query.QueryDefinition;
import org.labkey.api.query.QueryException;
import org.labkey.api.query.QueryForeignKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;

import org.apache.commons.text.CaseUtils;
import org.labkey.snprc_ehr.model.CalculatedColumn;
import org.labkey.snprc_ehr.model.CalculatedColumnQueryInfo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CalculatedColumnForeignKey extends LookupForeignKey
{
    private static final Logger _log = LogManager.getLogger(CalculatedColumnForeignKey.class);

    /* Query info object */
    private CalculatedColumnQueryInfo _queryInfo;

    /* SQL query to be used to calculate column values */
    private String _queryString;

    /**
     * Constructor
     * @param queryInfo
     * @param queryString
     */
    public CalculatedColumnForeignKey(CalculatedColumnQueryInfo queryInfo, String queryString) {
        _queryInfo = queryInfo;
        _queryString = queryString;
    }

    /**
     * Returns a table that contains the new foreign key columns that were calculated via SQL query
     * @return
     */
    @Override
    public TableInfo getLookupTableInfo() {

        AbstractTableInfo tableInfo = _queryInfo.getTableInfo();
        final String queryName = tableInfo.getPublicName();
        final String schemaName = tableInfo.getPublicSchemaName();
        final UserSchema targetSchema = tableInfo.getUserSchema();


        String name = queryName + CaseUtils.toCamelCase(_queryInfo.getLabel(), false);
        QueryDefinition queryDefinition = QueryService.get().createQueryDef(targetSchema.getUser(), targetSchema.getContainer(), targetSchema, name);
        queryDefinition.setSql(_queryString);

        List<QueryException> errors = new ArrayList<>();
        TableInfo lookupTable = queryDefinition.getTable(errors, true);
        if (errors.size() > 0) {
            _log.error("Error creating lookup table for: " + schemaName + "." + queryName + " in container: " + targetSchema.getContainer().getPath());
            errors.forEach(error -> _log.error(error.getMessage(), error));
            return null;
        }

        ((BaseColumnInfo)lookupTable.getColumn(_queryInfo.getPrimaryKeyColumn().getName())).setHidden(true);
        ((BaseColumnInfo)lookupTable.getColumn(_queryInfo.getPrimaryKeyColumn().getName())).setKeyField(true);

        for (CalculatedColumn column : _queryInfo.getCalculatedColumns()) {
            BaseColumnInfo columnInfo = ((BaseColumnInfo) lookupTable.getColumn(column.getColumnName()));
            columnInfo.setLabel(column.getLabel());
            columnInfo.setHidden(column.isHidden());
            if (column.getLookupTableKeyName() != null && column.getLookupTableName() != null && column.getLookupUrl() != null)
            {
                columnInfo.setFk(new QueryForeignKey(QueryForeignKey.from(targetSchema, tableInfo.getContainerFilter())
                        .table(column.getLookupTableName())
                        .key(column.getLookupTableKeyName())
                        .display(column.getLookupTableKeyName())));
                columnInfo.setURL(DetailsURL.fromString(column.getLookupUrl()));
            }
        }

        return lookupTable;
    }

}
