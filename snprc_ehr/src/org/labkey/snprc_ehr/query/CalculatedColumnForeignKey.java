/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.labkey.snprc_ehr.query;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.BaseColumnInfo;
import org.labkey.api.data.TableInfo;
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
import java.util.List;

public class CalculatedColumnForeignKey extends LookupForeignKey
{
    private static final Logger _log = LogManager.getLogger(CalculatedColumnForeignKey.class);

    /* Query info object */
    private final CalculatedColumnQueryInfo _queryInfo;

    /* SQL query to be used to calculate column values */
    private final String _queryString;

    /**
     * Constructor
     */
    public CalculatedColumnForeignKey(CalculatedColumnQueryInfo queryInfo, String queryString) {
        _queryInfo = queryInfo;
        _queryString = queryString;
    }

    /**
     * Returns a table that contains the new foreign key columns that were calculated via SQL query
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
        if (!errors.isEmpty()) {
            _log.error("Error creating lookup table for: {}.{} in container: {}", schemaName, queryName, targetSchema.getContainer().getPath());
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
