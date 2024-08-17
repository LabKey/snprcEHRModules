package org.labkey.snprc_ehr.helpers;

import org.apache.commons.lang.text.StrSubstitutor;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.text.CaseUtils;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.WrappedColumn;
import org.labkey.api.query.UserSchema;
import org.labkey.snprc_ehr.model.CalculatedColumn;
import org.labkey.snprc_ehr.model.CalculatedColumnQueryInfo;
import org.labkey.snprc_ehr.query.CalculatedColumnForeignKey;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static org.labkey.snprc_ehr.constants.QueryConstants.DATE_COLUMN_VARIABLE;
import static org.labkey.snprc_ehr.constants.QueryConstants.EHR_PATH_VARIABLE;
import static org.labkey.snprc_ehr.constants.QueryConstants.ID_COLUMN;
import static org.labkey.snprc_ehr.constants.QueryConstants.ID_COLUMN_VARIABLE;
import static org.labkey.snprc_ehr.constants.QueryConstants.PRIMARY_KEY_VARIABLE;
import static org.labkey.snprc_ehr.constants.QueryConstants.QUERY_VARIABLE;
import static org.labkey.snprc_ehr.constants.QueryConstants.SCHEMA_VARIABLE;
import static org.labkey.snprc_ehr.constants.QueryConstants.TARGET_CONTAINER_VARIABLE;

/**
 * Class that provides methods to build a table from a SQL query that contains columns to be calculated
 */
public class CustomizerQueryProvider
{
    /**
     * Constructor
     */
    public CustomizerQueryProvider() {

    }

    /**
     * Checks if the passed table exists, the primary key and id columns,
     * and builds table with calculated fields from SQL query. Returns false if any checks fail and
     * true if all checks pass and the table is successfully built
     * @param tableInfo
     * @param columnName
     * @param dateColumnName
     * @param queryString
     * @param ehrSchema
     * @param calculatedColumns
     * @param isRemovingDefaultCustomizerColumns
     * @return
     */
    public AbstractTableInfo getCalculatedColumnsTable(AbstractTableInfo tableInfo, String columnName, String dateColumnName,
                                       String queryString, UserSchema ehrSchema,
                                       Set<CalculatedColumn> calculatedColumns, boolean isRemovingDefaultCustomizerColumns) {
        /* Check if the column already exists in the table */
        if (tableInfo.getColumn(CaseUtils.toCamelCase(columnName, false), false) != null)
        {
            /* Check if the table should be removed so that it can be rebuilt. Applies to tables that require
            *  queries that are different from the DefaultEHRCustomizer's query */
            if (isRemovingDefaultCustomizerColumns)
                tableInfo.removeColumn(tableInfo.getColumn(CaseUtils.toCamelCase(columnName, false)));
            else
                return null;
        }

        final ColumnInfo primaryKeyColumn = getPrimaryKeyColumn(tableInfo);
        if (primaryKeyColumn == null)
            return null;
        final ColumnInfo idColumn = tableInfo.getColumn(ID_COLUMN);
        if(idColumn == null)
            return null;

        /* Build a query info object to be used by the foreign key class */
        CalculatedColumnQueryInfo queryInfo = getQueryInfo(tableInfo, primaryKeyColumn, idColumn, ehrSchema, columnName,
                calculatedColumns);

        /* Build a wrapped column object for the table */
        WrappedColumn calculatedColumn = getWrappedCalculatedColumn(queryInfo, mapQueryStringValues(queryString, queryInfo,
                dateColumnName));
        tableInfo.addColumn(calculatedColumn);
        return tableInfo;
    }

    /**
     * Obtain the column info for the primary key of a given table
     * @param tableInfo
     * @return
     */
    private ColumnInfo getPrimaryKeyColumn(TableInfo tableInfo) {
        List<ColumnInfo> primaryKeys = tableInfo.getPkColumns();
        return (primaryKeys.size() != 1) ? null : primaryKeys.get(0);
    }

    /**
     * Returns a new query info object to be used for calculating a column's info
     * @param tableInfo
     * @param primaryKeyColumn
     * @param idColumn
     * @param ehrSchema
     * @param label
     * @param calculatedColumns
     * @return
     */
    private CalculatedColumnQueryInfo getQueryInfo(AbstractTableInfo tableInfo, ColumnInfo primaryKeyColumn,
                                                   ColumnInfo idColumn, UserSchema ehrSchema,
                                                   String label, Set<CalculatedColumn> calculatedColumns)
    {
        CalculatedColumnQueryInfo queryInfo = new CalculatedColumnQueryInfo();
        queryInfo.setTableInfo(tableInfo);
        queryInfo.setCalculatedColumns(calculatedColumns);
        queryInfo.setPrimaryKeyColumn(primaryKeyColumn);
        queryInfo.setIdColumn(idColumn);
        queryInfo.setEhrSchema(ehrSchema);
        queryInfo.setLabel(label);

        return queryInfo;
    }

    /**
     * Returns a wrapped column object from a given query and it's information
     * @param queryInfo
     * @param queryString
     * @return
     */
    private WrappedColumn getWrappedCalculatedColumn(CalculatedColumnQueryInfo queryInfo, String queryString) {
        WrappedColumn column = new WrappedColumn(queryInfo.getPrimaryKeyColumn(), CaseUtils.toCamelCase(queryInfo.getLabel(),
                false));
        column.setLabel(queryInfo.getLabel());
        column.setReadOnly(true);
        column.setIsUnselectable(true);
        column.setUserEditable(false);
        /* Invokes the CalculatedColumnForeignKey class */
        column.setFk(new CalculatedColumnForeignKey(queryInfo, queryString));
        return column;
    }

    /**
     * Maps values from the query object's data to the variable names within the SQL query string
     * (formatted for the Apache Commons Lang StrSubstitor where ${variableName} maps to variableName)
     * @param queryString
     * @param queryInfo
     * @param dateColumnName
     * @return
     */
    private String mapQueryStringValues(String queryString, CalculatedColumnQueryInfo queryInfo, String dateColumnName) {
        Map<String, String> queryByValues = new HashMap<>();
        if(StringUtils.contains(queryString, PRIMARY_KEY_VARIABLE))
            queryByValues.put(PRIMARY_KEY_VARIABLE, queryInfo.getPrimaryKeyColumn().getFieldKey().toSQLString());
        if(StringUtils.contains(queryString, SCHEMA_VARIABLE))
            queryByValues.put(SCHEMA_VARIABLE, queryInfo.getTableInfo().getPublicSchemaName());
        if(StringUtils.contains(queryString, QUERY_VARIABLE))
            queryByValues.put(QUERY_VARIABLE, queryInfo.getTableInfo().getName());
        if(StringUtils.contains(queryString, EHR_PATH_VARIABLE))
            queryByValues.put(EHR_PATH_VARIABLE, queryInfo.getEhrSchema().getContainer().getPath());
        if(StringUtils.contains(queryString, ID_COLUMN_VARIABLE))
            queryByValues.put(ID_COLUMN_VARIABLE, queryInfo.getIdColumn().getFieldKey().toSQLString());
        if(StringUtils.contains(queryString, TARGET_CONTAINER_VARIABLE))
            queryByValues.put(TARGET_CONTAINER_VARIABLE, queryInfo.getTableInfo().getUserSchema().getName());
        if(StringUtils.contains(queryString, DATE_COLUMN_VARIABLE))
            queryByValues.put(DATE_COLUMN_VARIABLE, dateColumnName);
        return StrSubstitutor.replace(queryString, queryByValues);
    }
}
