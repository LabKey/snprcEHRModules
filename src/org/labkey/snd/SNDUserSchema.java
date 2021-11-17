/*
 * Copyright (c) 2017-2019 LabKey Corporation
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
package org.labkey.snd;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.collections.CaseInsensitiveTreeSet;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.roles.Role;
import org.labkey.snd.query.AttributeDataTable;
import org.labkey.snd.query.CategoriesTable;
import org.labkey.snd.query.EventDataTable;
import org.labkey.snd.query.EventNotesTable;
import org.labkey.snd.query.EventsCacheTable;
import org.labkey.snd.query.EventsTable;
import org.labkey.snd.query.LookupSetsTable;
import org.labkey.snd.query.LookupsTable;
import org.labkey.snd.query.PackageAttributeTable;
import org.labkey.snd.query.PackagesTable;
import org.labkey.snd.query.ProjectsTable;
import org.labkey.snd.query.SuperPackagesTable;

import java.util.Collections;
import java.util.Map;
import java.util.Set;


public class SNDUserSchema extends SimpleUserSchema implements UserSchema.HasContextualRoles
{
    private final Role _contextualRole;

    public SNDUserSchema(String name, @Nullable String description, User user, Container container, DbSchema dbschema)
    {
        super(name, description, user, container, dbschema);
        _contextualRole = null;
    }

    public SNDUserSchema(String name, @Nullable String description, User user, Container container, DbSchema dbschema, Role contextualRole)
    {
        super(name, description, user, container, dbschema);
        _contextualRole = contextualRole;
    }

    @Override
    public @NotNull Set<Role> getContextualRoles()
    {
        return null != _contextualRole ? Set.of(_contextualRole) : Set.of();
    }

    public enum TableType
    {
        SuperPkgs
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        return new SuperPackagesTable(schema, SNDSchema.getInstance().getTableInfoSuperPkgs(), cf).init();
                    }
                },
        Pkgs
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        return new PackagesTable(schema, SNDSchema.getInstance().getTableInfoPkgs(), cf).init();
                    }
                },
        PkgCategories
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        return new CategoriesTable(schema, SNDSchema.getInstance().getTableInfoPkgCategories(), cf).init();

                    }
                },
        PkgCategoryJunction
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        SimpleUserSchema.SimpleTable<SNDUserSchema> table =
                                new SimpleUserSchema.SimpleTable<>(
                                        schema, SNDSchema.getInstance().getTableInfoPkgCategoryJunction(), cf).init();

                        return table;
                    }
                },
        ProjectItems
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        SimpleUserSchema.SimpleTable<SNDUserSchema> table =
                                new SimpleUserSchema.SimpleTable<>(
                                        schema, SNDSchema.getInstance().getTableInfoProjectItems(), cf).init();

                        return table;
                    }
                },
        Projects
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        return new ProjectsTable(schema, SNDSchema.getInstance().getTableInfoProjects(), cf).init();
                    }
                },
        Events
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        return new EventsTable(schema, SNDSchema.getInstance().getTableInfoEvents(), cf).init();
                    }
                },
        EventNotes
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        if (schema.getContainer().hasPermission(schema.getUser(), AdminPermission.class, schema.getContextualRoles()))
                        {
                            return new EventNotesTable(schema, SNDSchema.getInstance().getTableInfoEventNotes(), cf).init();
                        }

                        return null;
                    }
                },
        EventData
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        if (schema.getContainer().hasPermission(schema.getUser(), AdminPermission.class, schema.getContextualRoles()))
                        {
                            return new EventDataTable(schema, SNDSchema.getInstance().getTableInfoEventData(), cf).init();
                        }

                        return null;
                    }
                },
        AttributeData
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        if (schema.getContainer().hasPermission(schema.getUser(), AdminPermission.class, schema.getContextualRoles()))
                        {
                            return new AttributeDataTable(schema, cf);
                        }

                        return null;
                    }
                },
        PackageAttribute
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        if (schema.getContainer().hasPermission(schema.getUser(), AdminPermission.class, schema.getContextualRoles()))
                        {
                            return new PackageAttributeTable(schema, cf);
                        }

                        return null;
                    }
                },
        Lookups
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        return new LookupsTable(schema, SNDSchema.getInstance().getTableInfoLookups(), cf).init();
                    }
                },
        LookupSets
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        SimpleUserSchema.SimpleTable<SNDUserSchema> table =
                                new SimpleUserSchema.SimpleTable<>(
                                        schema, SNDSchema.getInstance().getTableInfoLookupSets(), cf).init();

                        return table;
                    }
                },
        EventsCache
                {
                    @Override
                    public TableInfo createTable(SNDUserSchema schema, ContainerFilter cf)
                    {
                        if (schema.getContainer().hasPermission(schema.getUser(), AdminPermission.class, schema.getContextualRoles()))
                        {
                            return new EventsCacheTable(schema, SNDSchema.getInstance().getTableInfoEventsCache(), cf).init();
                        }

                        return null;
                    }
                };


        public abstract TableInfo createTable(SNDUserSchema schema, ContainerFilter cf);
    }

    @Override
    @Nullable
    public TableInfo createTable(String name, ContainerFilter cf)
    {
        if (name != null)
        {
            TableType tableType = null;
            for (TableType t : TableType.values())
            {
                // Make the enum name lookup case insensitive
                if (t.name().equalsIgnoreCase(name.toLowerCase()))
                {
                    tableType = t;
                    break;
                }
            }
            if (tableType != null)
            {
                return tableType.createTable(this, cf);
            }
            else
            {
                Map<String, Map<String, Object>> nameMap = getLookupSets();
                if (nameMap.containsKey(name))
                {
                    TableInfo table = SNDSchema.getInstance().getTableInfoLookups();
                    return new LookupSetsTable(this, table, name, nameMap.get(name), cf).init();
                }
            }
        }
        return null;
    }

    public Map<String, Map<String, Object>> getLookupSets()
    {
        Map<String, Map<String, Object>> nameMap = SNDManager.get().getCache().get(LookupSetsTable.getCacheKey(getContainer()));
        if (nameMap != null)
            return nameMap;

        nameMap = new CaseInsensitiveHashMap<>();

        TableSelector ts = new TableSelector(SNDSchema.getInstance().getTableInfoLookupSets(), new SimpleFilter(FieldKey.fromString("container"), getContainer().getId()), null);
        Map<String, Object>[] rows = ts.getMapArray();
        if (rows.length > 0)
        {
            Set<String> existing = super.getTableNames();
            for (Map<String, Object> row : rows)
            {
                String setname = (String)row.get("SetName");
                if (setname != null && !existing.contains(setname))
                    nameMap.put(setname, row);
            }
        }

        nameMap = Collections.unmodifiableMap(nameMap);
        SNDManager.get().getCache().put(LookupSetsTable.getCacheKey(getContainer()), nameMap);

        return nameMap;
    }

    @Override
    public Set<String> getTableNames()
    {
        Set<String> tables = new CaseInsensitiveTreeSet();
        tables.addAll(getLookupSets().keySet());
        tables.addAll(super.getTableNames());
        for (TableType tableType : TableType.values())
        {
            tables.add(tableType.name());
        }

        return tables;
    }

    @Override
    public Set<String> getVisibleTableNames()
    {
        Set<String> tables = new CaseInsensitiveTreeSet();
        tables.addAll(super.getVisibleTableNames());
        tables.addAll(getLookupSets().keySet());
        for (TableType tableType : TableType.values())
        {
            tables.add(tableType.name());
        }

        return tables;
    }
}