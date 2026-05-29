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

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import org.apache.commons.text.CaseUtils;

/**
 * Object containing Column information for data that will be calculated via SQL query
 * and added as a column to a table
 */
@Getter
@Setter
@AllArgsConstructor
public class CalculatedColumn
{

    private String columnName;

    private String label;

    private String lookupTableName;

    private String lookupTableKeyName;

    private String lookupUrl;

    private boolean isHidden;

    public CalculatedColumn(String label) {
        this.label = label;
        this.columnName = CaseUtils.toCamelCase(label, false);
        this.isHidden = false;
    }

    public CalculatedColumn(String label, boolean isHidden) {
        this.label = label;
        this.columnName = CaseUtils.toCamelCase(label, false);
        this.isHidden = isHidden;
    }

    public CalculatedColumn(String label, String lookupTableName, String lookupTableKeyName, String lookupUrl) {
        this.label = label;
        this.columnName = CaseUtils.toCamelCase(label, false);
        this.lookupTableName = lookupTableName;
        this.lookupTableKeyName = lookupTableKeyName;
        this.lookupUrl = lookupUrl;
        this.isHidden = false;
    }

    public CalculatedColumn(String label, String lookupTableName, String lookupTableKeyName, String lookupUrl, boolean isHidden) {
        this.label = label;
        this.columnName = CaseUtils.toCamelCase(label, false);
        this.lookupTableName = lookupTableName;
        this.lookupTableKeyName = lookupTableKeyName;
        this.lookupUrl = lookupUrl;
        this.isHidden = isHidden;
    }


}
