package org.labkey.snprc_ehr.table;

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

import static org.labkey.snprc_ehr.query.QueryConstants.AGE_AT_TIME_COLUMN;
import static org.labkey.snprc_ehr.query.QueryConstants.AGE_AT_TIME_DAYS_COLUMN;
import static org.labkey.snprc_ehr.query.QueryConstants.AGE_AT_TIME_MONTHS_COLUMN;
import static org.labkey.snprc_ehr.query.QueryConstants.AGE_AT_TIME_YEARS_COLUMN;
import static org.labkey.snprc_ehr.query.QueryConstants.AGE_AT_TIME_YEARS_ROUNDED_COLUMN;
import static org.labkey.snprc_ehr.query.QueryConstants.AGE_CLASS_AT_TIME_COLUMN;
import static org.labkey.snprc_ehr.query.QueryConstants.ANIMAL_TABLE;
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
    protected ColumnInfo getPrimaryKeyColumn(TableInfo tableInfo) {
        List<ColumnInfo> pks = tableInfo.getPkColumns();
        return (pks.size() != 1) ? null : pks.get(0);
    }

    protected CalculatedColumnQueryInfo getQueryInfo(AbstractTableInfo tableInfo, ColumnInfo primaryKeyColumn,
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


    protected boolean hasAnimalLookup(AbstractTableInfo tableInfo) {
        var idCol = tableInfo.getMutableColumn(ID_COLUMN);
        return idCol != null && idCol.getFk() != null && idCol.getFk().getLookupTableName().equalsIgnoreCase(ANIMAL_TABLE);
    }

    protected WrappedColumn getCalculatedColumn(CalculatedColumnQueryInfo queryInfo, String queryString) {
        WrappedColumn column = new WrappedColumn(queryInfo.getPrimaryKeyColumn(), CaseUtils.toCamelCase(queryInfo.getLabel(), false));
        column.setLabel(queryInfo.getLabel());
        column.setReadOnly(true);
        column.setIsUnselectable(true);
        column.setUserEditable(false);
        column.setFk(new CalculatedColumnForeignKey(queryInfo, queryString));
        return column;
    }

    protected String mapQueryStringValues(String queryString, CalculatedColumnQueryInfo queryInfo) {
        Map<String, String> queryByValues = new HashMap<>();
        queryByValues.put(PRIMARY_KEY_VARIABLE, queryInfo.getPrimaryKeyColumn().getFieldKey().toSQLString());
        queryByValues.put(SCHEMA_VARIABLE, queryInfo.getTableInfo().getPublicSchemaName());
        queryByValues.put(QUERY_VARIABLE, queryInfo.getTableInfo().getName());
        queryByValues.put(EHR_PATH_VARIABLE, queryInfo.getEhrSchema().getContainer().getPath());
        queryByValues.put(ID_COLUMN_VARIABLE, queryInfo.getIdColumn().getFieldKey().toSQLString());
        queryByValues.put(TARGET_CONTAINER_VARIABLE, queryInfo.getTableInfo().getUserSchema().getName());
        return StrSubstitutor.replace(queryString, queryByValues);

    }

    protected List<CalculatedColumn> getCalculatedColumns(List<String> columnNames) {
        List<CalculatedColumn> calculatedColumns = new ArrayList<>();
        for (String columnName : columnNames) {
            calculatedColumns.add(new CalculatedColumn(CaseUtils.toCamelCase(columnName, true), columnName, false));
        }
        return calculatedColumns;
    }
}
