/*
 * Copyright (c) 2017 LabKey Corporation
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
package org.labkey.snprc_ehr.table;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.DataColumn;
import org.labkey.api.data.DisplayColumn;
import org.labkey.api.data.DisplayColumnFactory;
import org.labkey.api.data.RenderContext;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.util.PageFlowUtil;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by thawkins on 4/17/2017.
 *
 */

/**
 * Creates an HTML table element for the "demographicsActiveAccount.account" column
 * to display the active account # along with additional information within the column.
 *
 * <p>
 * @see "SNPRC_EHRCustomizer.java and demographicsActiveAccount.query.xml for usage"
 *
 */
public class AnimalAccountDisplayColumnFactory implements DisplayColumnFactory
{
    @Override
    public DisplayColumn createRenderer(ColumnInfo colInfo)
    {
        return new AnimalAccountDisplayColumn(colInfo);
    }

    public class AnimalAccountDisplayColumn extends DataColumn
    {

        public AnimalAccountDisplayColumn(ColumnInfo col)
        {
            super(col,false);
            setRequiresHtmlFiltering(false);
        }


        public Map<String, Object> getDataMap(RenderContext ctx)
        {
            Object value = ctx.get(getBoundColumn().getFieldKey());
            if (value == null)
                return new HashMap<>();

            String id = ctx.get("id").toString();

            UserSchema schema = QueryService.get().getUserSchema(ctx.getViewContext().getUser(), ctx.getContainer(), "study");
            TableInfo table = schema.getTable("demographicsActiveAccount");
            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("id"), id, CompareType.EQUAL);

            return new TableSelector(table, filter, null).getMap();
        }

        @NotNull
        @Override
        public String getFormattedValue(RenderContext ctx)
        {

            if (ctx == null)
                throw new IllegalArgumentException("Invalid argument passed for RenderContext ctx");

            Map<String, Object> dataMap = this.getDataMap(ctx);
            if (dataMap.isEmpty())
                return "";

            ArrayList<String> errors = new ArrayList<>();
            SimpleDateFormat dateFormat = new SimpleDateFormat("MM-dd-yy");

            StringBuilder sb = new StringBuilder();
            sb.append("<table border=1 style='border-collapse: collapse;'><colgroup><col width='110'><col width='110'><col width='130'></colgroup>");
            //sb.append("<th>Account</th><th>Start Date</th><th>Group</th>");
            sb.append("<tr><td>" + PageFlowUtil.filter(dataMap.get("account")) + "</td>" );
            sb.append("<td>" + dateFormat.format(dataMap.get("date")) + "</td>");
            sb.append("<td>" + PageFlowUtil.filter(dataMap.get("accountGroup")) + "</td></tr></table>");

            String html = PageFlowUtil.validateHtml(sb.toString(), errors, false);
            if (errors.isEmpty())
                return html;
            else
                return PageFlowUtil.filter(errors.get(0));
        }

        @NotNull
        @Override
        public Object getExcelCompatibleValue(RenderContext ctx)
        {

            if (ctx == null)
                throw new IllegalArgumentException("Invalid argument passed for RenderContext ctx");

            Map<String, Object> dataMap = this.getDataMap(ctx);
            if (dataMap.isEmpty())
                return "";

            ArrayList<String> errors = new ArrayList<>();
            SimpleDateFormat dateFormat = new SimpleDateFormat("MM-dd-yy");

            StringBuilder sb = new StringBuilder();
            sb.append("Account: " + dataMap.get("account") + "  " );
            sb.append("Date: " + dateFormat.format(dataMap.get("date")) + "  ");
            sb.append("Account Groups: " + dataMap.get("accountGroup"));

            return sb.toString();
        }

    }


}
