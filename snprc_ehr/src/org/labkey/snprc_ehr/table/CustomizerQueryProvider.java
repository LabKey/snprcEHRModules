package org.labkey.snprc_ehr.table;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.text.StrSubstitutor;
import org.apache.commons.text.CaseUtils;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.WrappedColumn;
import org.labkey.api.query.UserSchema;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.labkey.snprc_ehr.query.QueryConstants.DATE_COLUMN_VARIABLE;
import static org.labkey.snprc_ehr.query.QueryConstants.EHR_PATH_VARIABLE;
import static org.labkey.snprc_ehr.query.QueryConstants.ID_COLUMN;
import static org.labkey.snprc_ehr.query.QueryConstants.ID_COLUMN_VARIABLE;
import static org.labkey.snprc_ehr.query.QueryConstants.PRIMARY_KEY_VARIABLE;
import static org.labkey.snprc_ehr.query.QueryConstants.QUERY_VARIABLE;
import static org.labkey.snprc_ehr.query.QueryConstants.SCHEMA_VARIABLE;
import static org.labkey.snprc_ehr.query.QueryConstants.TARGET_CONTAINER_VARIABLE;

public class CustomizerQueryProvider
{
    CustomizerQueryProvider() {

    }

    protected boolean buildTableFromQuery(AbstractTableInfo tableInfo, String columnName, String dateColumnName, String queryString, UserSchema ehrSchema,
                                          List<String> calculatedColumnNames, boolean isRemovingDefaultTable) {
        if (tableInfo.getColumn(CaseUtils.toCamelCase(columnName, false), false) != null)
        {
            if (isRemovingDefaultTable)
                tableInfo.removeColumn(tableInfo.getColumn(CaseUtils.toCamelCase(columnName, false)));
            else
                return false;
        }
        final ColumnInfo primaryKeyColumn = getPrimaryKeyColumn(tableInfo);
        if (primaryKeyColumn == null)
            return false;
        final ColumnInfo idColumn = tableInfo.getColumn(ID_COLUMN);
        if(idColumn == null)
            return false;

        CalculatedColumnQueryInfo queryInfo = getQueryInfo(tableInfo, primaryKeyColumn, idColumn, ehrSchema, columnName, getCalculatedColumns(calculatedColumnNames));
        WrappedColumn caluclatedColumn = getWrappedCalculatedColumn(queryInfo, mapQueryStringValues(queryString, queryInfo, dateColumnName));
        tableInfo.addColumn(caluclatedColumn);
        return true;
    }

    private List<CalculatedColumn> getCalculatedColumns(List<String> columnNames) {
        List<CalculatedColumn> calculatedColumns = new ArrayList<>();
        for (String columnName : columnNames) {
            calculatedColumns.add(new CalculatedColumn(CaseUtils.toCamelCase(columnName, true), columnName, false));
        }
        return calculatedColumns;
    }

    private ColumnInfo getPrimaryKeyColumn(TableInfo tableInfo) {
        List<ColumnInfo> pks = tableInfo.getPkColumns();
        return (pks.size() != 1) ? null : pks.get(0);
    }

    private CalculatedColumnQueryInfo getQueryInfo(AbstractTableInfo tableInfo, ColumnInfo primaryKeyColumn,
                                                   ColumnInfo idColumn, UserSchema ehrSchema,
                                                   String label, List<CalculatedColumn> calculatedColumns)
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

    private WrappedColumn getWrappedCalculatedColumn(CalculatedColumnQueryInfo queryInfo, String queryString) {
        WrappedColumn column = new WrappedColumn(queryInfo.getPrimaryKeyColumn(), CaseUtils.toCamelCase(queryInfo.getLabel(), false));
        column.setLabel(queryInfo.getLabel());
        column.setReadOnly(true);
        column.setIsUnselectable(true);
        column.setUserEditable(false);
        column.setFk(new CalculatedColumnForeignKey(queryInfo, queryString));
        return column;
    }

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
