/*
 * Copyright (c) 2026 LabKey Corporation
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
package org.labkey.snprc_ehr;

import org.apache.logging.log4j.Logger;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.DbScope.Transaction;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SchemaTableInfo;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.UpgradeCode;
import org.labkey.api.exp.OntologyManager;
import org.labkey.api.module.ModuleContext;
import org.labkey.api.specimen.model.SpecimenTablesProvider;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.api.util.logging.LogHelper;

import java.util.List;

public class SNPRC_EHRUpgradeCode implements UpgradeCode
{
    private static final Logger LOG = LogHelper.getLogger(SNPRC_EHRUpgradeCode.class, "SNPRC_EHR upgrade status");

    /**
     * Called from snprc_ehr-26.000-26.001.sql
     *
     * For every PropertyDescriptor in the specimen storage schema, verify that its StorageColumnName
     * matches an actual column in the provisioned table. If not, and the descriptor's Name resolves
     * to a real column, update StorageColumnName to that column's physical (DB-metadata) name so the
     * value will still match after migration to a case-sensitive database.
     */
    @SuppressWarnings("unused")
    public static void fixSpecimenStorageColumnNames(ModuleContext context)
    {
        if (context.isNewInstall())
            return;

        TableInfo tinfoDomainDescriptor = OntologyManager.getTinfoDomainDescriptor();
        TableInfo tinfoPropertyDomain = OntologyManager.getTinfoPropertyDomain();
        TableInfo tinfoPropertyDescriptor = OntologyManager.getTinfoPropertyDescriptor();

        DbScope scope = tinfoPropertyDescriptor.getSchema().getScope();
        DbSchema specimenSchema = DbSchema.get(SpecimenTablesProvider.SCHEMA_NAME, DbSchemaType.Provisioned);

        SQLFragment sql = new SQLFragment("SELECT px.PropertyId, dd.StorageSchemaName, dd.StorageTableName, px.StorageColumnName, px.Name FROM ")
            .append(tinfoDomainDescriptor, "dd")
            .append(" INNER JOIN ")
            .append(tinfoPropertyDomain, "pd")
            .append(" ON dd.DomainId = pd.DomainId INNER JOIN ")
            .append(tinfoPropertyDescriptor, "px")
            .append(" ON pd.PropertyId = px.PropertyId ")
            .append("WHERE dd.StorageSchemaName = ?").add(SpecimenTablesProvider.SCHEMA_NAME)
            .append(" AND dd.StorageTableName IS NOT NULL AND px.StorageColumnName IS NOT NULL");

        List<PropertyRow> properties = new SqlSelector(scope, sql).getArrayList(PropertyRow.class);
        LOG.info("Checking {} PropertyDescriptors in specimen storage schema '{}'", properties.size(), SpecimenTablesProvider.SCHEMA_NAME);

        int updated = 0;
        int skipped = 0;
        int alreadyCorrect = 0;
        try (Transaction tx = scope.ensureTransaction())
        {
            for (PropertyRow row : properties)
            {
                SchemaTableInfo provisioned = specimenSchema.getTable(row.storageTableName());
                if (provisioned == null)
                {
                    LOG.warn("Provisioned table '{}.{}' does not exist; skipping property '{}'",
                            row.storageSchemaName(), row.storageTableName(), row.name());
                    skipped++;
                    continue;
                }

                if (provisioned.getColumn(row.storageColumnName()) != null)
                {
                    LOG.debug("Property '{}' in '{}.{}': StorageColumnName '{}' already resolves; nothing to update",
                            row.name(), row.storageSchemaName(), row.storageTableName(), row.storageColumnName());
                    alreadyCorrect++;
                    continue;
                }

                ColumnInfo byName = provisioned.getColumn(row.name());
                if (byName == null)
                {
                    LOG.warn("Property '{}' in '{}.{}': neither StorageColumnName '{}' nor Name '{}' exists in provisioned table; skipping",
                            row.name(), row.storageSchemaName(), row.storageTableName(), row.storageColumnName(), row.name());
                    skipped++;
                    continue;
                }

                String newStorageColumnName = byName.getMetaDataIdentifier().getId();
                LOG.info("Updating StorageColumnName from '{}' to '{}' for property '{}' in table '{}.{}'",
                        row.storageColumnName(), newStorageColumnName, row.name(), row.storageSchemaName(), row.storageTableName());
                Table.update(null, tinfoPropertyDescriptor, PageFlowUtil.map("StorageColumnName", newStorageColumnName), row.propertyId());
                updated++;
            }
            tx.commit();
        }

        LOG.info("Specimen StorageColumnName fix complete: {} updated, {} skipped, {} already correct",
                updated, skipped, alreadyCorrect);
    }

    public record PropertyRow(int propertyId, String storageSchemaName, String storageTableName, String storageColumnName, String name) {}
}
