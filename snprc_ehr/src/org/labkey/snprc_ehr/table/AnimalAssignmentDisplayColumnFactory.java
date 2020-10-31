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
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.UserSchema;
import org.labkey.api.util.HtmlString;
import org.labkey.api.util.PageFlowUtil;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

/**
 * Created by thawkins on 4/24/2017.
 * @author thawkins
 */

/**
 * Creates an HTML table element for the "demographicsActiveAssignment.protocol" column
 * to display the complete list of active IACUC assignments and related info in a sub-table
 * within the column.
 *
 * <p>
 * @see "SNPRC_EHRCustomizer.java and demographicsActiveAssignment.query.xml for usage"
 *
 */
public class AnimalAssignmentDisplayColumnFactory implements DisplayColumnFactory
{
    @Override
    public DisplayColumn createRenderer(ColumnInfo colInfo)
    {
        return new AnimalAssignmentDisplayColumnFactory.AnimalAssignmentDisplayColumn(colInfo);
    }


    public class AnimalAssignmentDisplayColumn extends DataColumn
    {
        private ColumnInfo col;

        public AnimalAssignmentDisplayColumn(ColumnInfo col)
        {
            super(col,false);
            setRequiresHtmlFiltering(false);
            this.col = col;
        }

        private TableSelector getTs(RenderContext ctx)
        {

            Object value = ctx.get(getBoundColumn().getFieldKey());
            if (value == null)
                return null;

            String id = ctx.get("id").toString();

            UserSchema schema = QueryService.get().getUserSchema(ctx.getViewContext().getUser(), ctx.getContainer(), "study");
            TableInfo table = schema.getTable("assignment");
            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("id"), id, CompareType.EQUAL);
            filter.addClause(new SimpleFilter.AndClause(
                    new CompareType.CompareClause(FieldKey.fromString("enddate"), CompareType.ISBLANK, null))
            );
            filter.addClause(new SimpleFilter.OrClause(
                    new CompareType.CompareClause(FieldKey.fromString("assignmentStatus"), CompareType.EQUAL, "A"),
                    new CompareType.CompareClause(FieldKey.fromString("assignmentStatus"), CompareType.EQUAL, "S"),
                    new CompareType.CompareClause(FieldKey.fromString("assignmentStatus"), CompareType.EQUAL, "H")
            ));

            return new TableSelector(table, PageFlowUtil.set("protocol", "date", "assignmentStatus", "remark"), filter, new Sort("date"));
        }



        @NotNull
        @Override
        public HtmlString getFormattedHtml(RenderContext ctx)
        {
            // Other LK code overriding this method fail to evaluate the argument prior to using it.  Should it be checked? tjh
            if (ctx == null)
                throw new IllegalArgumentException("Invalid argument passed for RenderContext ctx");

           TableSelector ts = this.getTs(ctx);
           if (ts == null)
              return HtmlString.EMPTY_STRING;

            SimpleDateFormat dateFormat = new SimpleDateFormat("MM-dd-yy");

            StringBuilder sb = new StringBuilder();
            sb.append("<table border=1 style='border-collapse: collapse;border: 3px'><colgroup><col width='80'><col width='110'><col width='40'><col width='150'></colgroup>");
            //sb.append("<th>Protocol</th><th>Date</th><th>Status</th><th>Comment</th>");

            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    String protocol = PageFlowUtil.filter(rs.getString("protocol"));
                    String date = dateFormat.format(rs.getDate("date"));
                    String assignmentStatus = PageFlowUtil.filter(rs.getString("assignmentStatus"));
                    String remark = PageFlowUtil.filter(rs.getString("remark"));
                           //remark = (remark == null) ? "" : remark;
                    sb.append("<tr><td>" + protocol + "</td><td>" + date + "</td><td>" + assignmentStatus + "</td>");
                    sb.append("<td>" + remark +  "</td>" + "<td></tr>");
                }
            });
            sb.append("</table>");

            ArrayList<String> errors = new ArrayList<>();
            String html = PageFlowUtil.validateHtml(sb.toString(), errors, false);
            if (errors.isEmpty())
                return HtmlString.unsafe(html);
            else
                return HtmlString.of(errors.get(0));
        }

        @NotNull
        @Override
        public Object getExcelCompatibleValue(RenderContext ctx)
        {

            if (ctx == null)
                throw new IllegalArgumentException("Invalid argument passed for RenderContext ctx");

            TableSelector ts = this.getTs(ctx);
            if (ts == null)
                return "";

            SimpleDateFormat dateFormat = new SimpleDateFormat("MM-dd-yy");

            StringBuilder sb = new StringBuilder();
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    String protocol = rs.getString("protocol");
                    String date = dateFormat.format(rs.getDate("date"));
                    String assignmentStatus = rs.getString("assignmentStatus");
                    String remark = rs.getString("remark");

                    sb.append("Protocol: " + protocol + "  " + "Date: " + date + "  " + "Status: " + assignmentStatus);
                    if (remark != null)
                        sb.append("  " + "Comment: " + remark);
                    sb.append("\n");
                }
            });

            return sb.toString();
        }

    }
}
