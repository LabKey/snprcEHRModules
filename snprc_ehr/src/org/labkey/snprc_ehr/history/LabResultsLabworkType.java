/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
package org.labkey.snprc_ehr.history;


import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.history.DefaultLabworkType;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.util.PageFlowUtil;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

/**
 * Created by bimber on 1/23/2015.
 * 1/26/2015 Changed "Lab Results" to "LabworkResults".  tjh
 * 2/5/2015  Changes made to getLine() to improve format of results. tjh
 * 2/13/2015 Merged with SortingLabworkType.java. tjh
 * 2/16/2015 Optimized _testType retrieval. tjh
 */
public class LabResultsLabworkType extends DefaultLabworkType
{
    protected String _test_nameField = "test_name";
    protected String _sortField = "sort_order";
    protected String _runid_typeField = "runid/type";
    protected String _default_testType = "LabworkResults";

    private static String _testType;
    private String _testCol = "testid";
    private String _sortCol = "sort_order";
    private Map<String, Integer> _tests = null;

    public LabResultsLabworkType(Module module)
    {
        //terry - is 'Lab Results' what you used for test_type?
        super("Labwork Results", "study", "LabworkResults", module);
        _testType = _default_testType;  // this is just a temporary value it will be updated for the specific
                                        // assay type in the getRows() method. tjh
        _normalRangeField = "refRange";
        _unitsField = "units";
        _normalRangeStatusField = "abnormal_flags";
    }

    /**
     * Specify the columns you want returned here
     */
    @Override
    protected Set<String> getColumnNames()
    {
        return PageFlowUtil.set(_idField, _dateField, _runIdField, _testIdField, _resultField, _qualResultField, _test_nameField,
                _unitsField, _normalRangeField, _normalRangeStatusField, _sortField, _runid_typeField);
    }

    @Override
    protected String getLine(Results rs, boolean redacted) throws SQLException
    {
        StringBuilder sb = new StringBuilder();
        String testId = getTestId(rs);
        Double result = _resultField == null ?  null : rs.getDouble(FieldKey.fromString(_resultField));
        String units = _unitsField == null ?  null : rs.getString(FieldKey.fromString(_unitsField));
        String testName = _test_nameField == null ?  null : rs.getString(FieldKey.fromString(_test_nameField));
        String qualResult = _qualResultField == null ?  null : rs.getString(FieldKey.fromString(_qualResultField));
        String refRange = _normalRangeField == null ?  null : rs.getString(FieldKey.fromString(_normalRangeField));
        String abnormalFlags = _normalRangeStatusField == null ?  null : rs.getString(FieldKey.fromString(_normalRangeStatusField));

        if (result != null || qualResult != null)
        {
            //col 1
            sb.append("<td style='padding: 2px;'>").append(testName).append("<font size='1'>").append(" (").append(testId).append(") </font>").append("</td>");

            // col 2
            sb.append("<td style='padding: 2px;'>");
            if (qualResult != null)
            {
                sb.append(": ").append(qualResult);
                if (units != null)
                {
                    sb.append("   ").append(units);
                }
            }

            sb.append("</td>");

            // col 3
            sb.append("<td style='padding: 2px;'>");
            if (refRange != null)
            {
                sb.append("Normal Range: ").append(refRange);

                if (abnormalFlags != null)
                {
                    sb.append(" **ABNORMAL - ").append(abnormalFlags);
                }
            }
            sb.append("</td>");

        }
        return sb.toString();
    }

    private Map<String, Integer> loadTests(boolean forceRefresh)
    {
        if (forceRefresh || _tests == null)
        {
            TableInfo ti = DbSchema.get("snprc_ehr", DbSchemaType.Module).getTable("lab_tests");
            assert ti != null;

            _tests = new CaseInsensitiveHashMap<>();
            TableSelector ts = new TableSelector(ti, PageFlowUtil.set(_sortCol, _testCol), new SimpleFilter(FieldKey.fromString("type"), _testType), null);
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    if (rs.getObject(_sortCol) != null)
                        _tests.put(rs.getString(_testCol), rs.getInt(_sortCol));
                }
            });
        }
        return _tests;
    }

    @Override
    protected Map<String, List<String>> getRows(TableSelector ts, final Collection<ColumnInfo> cols, final boolean redacted)
    {
        final Map<String, Map<Integer, List<String>>> rows = new HashMap<>();
        ts.forEach(new Selector.ForEachBlock<ResultSet>()
                   {
                       boolean forceRefresh = true;
                       @Override
                       public void exec(ResultSet object) throws SQLException
                       {

                           Results rs = new ResultsImpl(object, cols);
                           String runId = rs.getString(FieldKey.fromString("runId"));

                           if (forceRefresh)
                           {
                               String assayType = rs.getString(FieldKey.fromString(_runid_typeField));
                               if (assayType != _testType )
                                 _testType = assayType == null ? _default_testType : assayType;
                               else
                                   forceRefresh = false;
                           }

                           Map<Integer, List<String>> map = rows.get(runId);
                           if (map == null)
                               map = new TreeMap<>();

                           Integer sort = getSortOrder(rs, forceRefresh);
                           forceRefresh = false;

                           List<String> list = map.get(sort);
                           if (list == null)
                               list = new ArrayList<>();

                           String line = getLine(rs, redacted);
                           if (line != null)

                               list.add(line);

                           map.put(sort, list);
                           rows.put(runId, map);
                       }
                   }
        );

        Map<String, List<String>> sortedResults = new HashMap<>();
        for (String runId : rows.keySet())
        {
            List<String> sorted = new ArrayList<>();
            Map<Integer, List<String>> map = rows.get(runId);
            for (Integer sort : map.keySet())
            {
                sorted.addAll(map.get(sort));
            }

            sortedResults.put(runId, sorted);
        }
        return sortedResults;
    }

    protected Integer getSortOrder(ResultSet rs, boolean forceRefresh) throws SQLException
    {
        String testId = rs.getString(_testIdField);
        if (testId == null)
            return 9999;

        loadTests(forceRefresh);
        return _tests.containsKey(testId) ? _tests.get(testId) : 9999;
    }
}