/*
 * Copyright (c) 2013-2017 LabKey Corporation
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

import org.apache.log4j.Logger;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager;
import org.labkey.api.data.RuntimeSQLException;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.security.UserManager;
import org.labkey.api.util.PageFlowUtil;
import org.labkey.snprc_ehr.SNPRC_EHRSchema;

import javax.validation.constraints.Null;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class SNPRC_EHRTriggerHelper
{
    private static final Logger _log = Logger.getLogger(SNPRC_EHRTriggerHelper.class);
    private Container _container = null;
    private User _user = null;
    private Map<String, TableInfo> _cachedTables = new HashMap<>();



    public SNPRC_EHRTriggerHelper(int userId, String containerId)
    {
        _user = UserManager.getUser(userId);
        if (_user == null)
            throw new RuntimeException("User does not exist: " + userId);

        _container = ContainerManager.getForId(containerId);
        if (_container == null)
            throw new RuntimeException("Container does not exist: " + containerId);

    }

    private User getUser()
    {
        return _user;
    }

    private Container getContainer()
    {
        return _container;
    }

    /**
     * Should we close datasets on animal departure?
     *
     * @param Id   Animal ID
     * @param date departure Date
     * @return true if datasets should be closed, false otherwise
     */
    public boolean shouldCloseDataSets(String Id, Date date)
    {
        //Given Animal Id and Departure Date, Lookup Arrivals that occurred after the departure date; if any, return false; return true otherwise
        UserSchema schema = QueryService.get().getUserSchema(this.getUser(), this.getContainer(), "study");
        TableInfo table = schema.getTable("Arrival");

        SimpleFilter filter = new SimpleFilter();
        filter.addCondition(FieldKey.fromString("id"), Id, CompareType.EQUAL);
        filter.addCondition(FieldKey.fromString("date"), date, CompareType.DATE_GTE);


        TableSelector tableSelector = new TableSelector(table, filter, null);
        List<Object> arrivals = tableSelector.getArrayList(Object.class);

        return arrivals.isEmpty();


    }

    /**
     * Auto-generate the next vet ID
     *
     * @return integer
     */
    public Integer getNextVetCode()
    {
        SQLFragment sql = new SQLFragment("SELECT MAX(vetid) AS MAX_CODE FROM ");
        sql.append(SNPRC_EHRSchema.getInstance().getTableInfoValidVets());
        SqlSelector sqlSelector = new SqlSelector(SNPRC_EHRSchema.getInstance().getSchema(), sql);

        Integer vetId = sqlSelector.getObject(Integer.class);

        // if table has been truncated - reseed the vetId at 1
        return (vetId == null) ? 1 : vetId + 1;
    }


    public Map<String, Object> getExtraContext()
    {
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("quickValidation", true);
        map.put("generatedByServer", true);

        return map;
    }
    private TableInfo getTableInfo(String schemaName, String queryName)
    {
        String key = schemaName + "||" + queryName;

        if (_cachedTables.containsKey(key))
            return _cachedTables.get(key);

        UserSchema us = QueryService.get().getUserSchema(getUser(), getContainer(), schemaName);
        if (us == null)
        {
            _cachedTables.put(key, null);
            if (us == null)
                throw new IllegalArgumentException("Unable to find schema: " + schemaName);
        }

        TableInfo ti = us.getTable(queryName);
        if (ti == null)
            throw new IllegalArgumentException("Unable to find table: " + schemaName + "." + queryName);

        _cachedTables.put(key, ti);

        return _cachedTables.get(key);
    }

    public void ensureSingleFlagCategoryActive(String id, String flag, String objectId, final Date enddate)
    {
        //first resolve flag
        // the code column is being used as the fk column in the SNPRC module
        TableInfo flagValuesTable = getTableInfo("ehr_lookups", "flag_values");
        TableSelector ts1 =  new TableSelector(flagValuesTable, Collections.singleton("category"), new SimpleFilter(FieldKey.fromString("code"), flag), null);
        String category = ts1.getObject(String.class);
        if (category == null)
        {
            return;
        }

        TableInfo flagCategoriesTable = getTableInfo("ehr_lookups", "flag_categories");
        TableSelector ts2 =  new TableSelector(flagCategoriesTable, Collections.singleton("enforceUnique"), new SimpleFilter(FieldKey.fromString("category"), category), null);
        List<Boolean> ret = ts2.getArrayList(Boolean.class);
        boolean enforceUnique = ret != null && ret.size() == 1 ? ret.get(0) : false;

        if (enforceUnique)
        {
            //find existing active flags of the same category
            SimpleFilter filter = new SimpleFilter(FieldKey.fromString("flag/category"), category);
            filter.addCondition(FieldKey.fromString("isActive"), true);
            filter.addCondition(FieldKey.fromString("Id"), id, CompareType.EQUAL);
            filter.addCondition(FieldKey.fromString("objectid"), objectId, CompareType.NEQ_OR_NULL);

            TableInfo flagsTable = getTableInfo("study", "Animal Record Flags");
            final List<Map<String, Object>> rows = new ArrayList<>();
            final List<Map<String, Object>> oldKeys = new ArrayList<>();
            QueryUpdateService qus = flagsTable.getUpdateService();

            TableSelector ts = new TableSelector(flagsTable, PageFlowUtil.set("lsid", "Id", "enddate"), filter, null);
            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    Map<String, Object> row = new CaseInsensitiveHashMap<>();
                    row.put("enddate", enddate);
                    rows.add(row);

                    Map<String, Object> keys = new CaseInsensitiveHashMap<>();
                    keys.put("lsid", rs.getString("lsid"));
                    oldKeys.add(keys);
                }
            });

            try
            {
                if (rows.size() > 0)
                {
                    Map<String, Object> extraContext = getExtraContext();
                    extraContext.put("skipAnnounceChangedParticipants", true);
                    qus.updateRows(getUser(), flagsTable.getUserSchema().getContainer(), rows, oldKeys, null, extraContext);
                }
            }
            catch (InvalidKeyException e)
            {
                throw new RuntimeException(e);
            }
            catch (BatchValidationException e)
            {
                throw new RuntimeException(e);
            }
            catch (QueryUpdateServiceException e)
            {
                throw new RuntimeException(e);
            }
            catch (SQLException e)
            {
                throw new RuntimeSQLException(e);
            }
        }
    }

}
