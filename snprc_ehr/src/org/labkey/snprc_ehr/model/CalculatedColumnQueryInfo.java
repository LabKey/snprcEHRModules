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
package org.labkey.snprc_ehr.model;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.query.UserSchema;
import org.labkey.snprc_ehr.model.CalculatedColumn;

import java.util.Set;

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

    private Set<CalculatedColumn> calculatedColumns;

}
