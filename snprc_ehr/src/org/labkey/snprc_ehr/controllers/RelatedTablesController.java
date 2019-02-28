/*
 * Copyright (c) 2017-2018 LabKey Corporation
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
package org.labkey.snprc_ehr.controllers;

import org.json.JSONArray;
import org.json.JSONObject;
import org.labkey.api.action.ApiAction;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.SimpleApiJsonForm;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.Selector.ForEachBlock;
import org.labkey.api.data.SqlExecutor;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.ehr.dataentry.DataEntryForm;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.WebPartView;
import org.labkey.snprc_ehr.SNPRC_EHRSchema;
import org.labkey.snprc_ehr.security.ManageRelatedTablesPermission;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by lkacimi on 4/12/2017.
 */
public class RelatedTablesController extends SpringActionController
{
    public static final String NAME = "RelatedTables";
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(RelatedTablesController.class);

    public RelatedTablesController()
    {
        setActionResolver(_actionResolver);
    }

    @RequiresPermission(ManageRelatedTablesPermission.class)
    public class GetValidInstitutionsViewAction extends SimpleViewAction<Object>
    {

        @Override
        public ModelAndView getView(Object form, BindException errors)
        {

            JspView<DataEntryForm> view = new JspView("/org/labkey/snprc_ehr/views/ValidInstitutions.jsp", this);
            view.setTitle("Valid Institutions");
            view.setHidePageTitle(true);
            view.setFrame(WebPartView.FrameType.PORTAL);


            return view;
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("Valid Institutions");
        }
    }

    @RequiresPermission(ManageRelatedTablesPermission.class)
    public class GetValidVetsAction extends SimpleViewAction<Object>
    {

        @Override
        public ModelAndView getView(Object form, BindException errors)
        {

            JspView<DataEntryForm> view = new JspView("/org/labkey/snprc_ehr/views/ValidVets.jsp", this);
            view.setTitle("Valid Vets");
            view.setHidePageTitle(true);
            view.setFrame(WebPartView.FrameType.PORTAL);


            return view;
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("Valid Vets");
        }
    }

    /**
     * CRUD lookups
     */

    @RequiresPermission(AdminPermission.class)
    public class GetPopulateLookupsViewAction extends SimpleViewAction<SimpleApiJsonForm>
    {
        @Override
        public ModelAndView getView(SimpleApiJsonForm form, BindException errors)
        {

            JspView<DataEntryForm> view = new JspView("/org/labkey/snprc_ehr/views/PopulateLookups.jsp", this);
            view.setTitle("Populate lookups");
            view.setHidePageTitle(true);
            view.setFrame(WebPartView.FrameType.PORTAL);


            return view;
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root.addChild("Populate lookups");
        }

    }

    @RequiresPermission(AdminPermission.class)
    public class GetLookupSetsAction extends ReadOnlyApiAction<SimpleApiJsonForm>
    {
        public ApiResponse execute(SimpleApiJsonForm form, BindException errors)
        {
            SQLFragment sql = new SQLFragment("SELECT setname, label FROM ");
            sql.append(SNPRC_EHRSchema.getInstance().getTableInfoLookupSets());
            sql.append(" ORDER BY label");
            List<JSONObject> sets = new ArrayList<JSONObject>();
            Map<String, Object> props = new HashMap<String, Object>();

            new SqlSelector(SNPRC_EHRSchema.getInstance().getSchema(), sql).forEach(new ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    JSONObject set = new JSONObject();
                    set.put("value", rs.getString("setname"));
                    set.put("label", rs.getString("label"));

                    sets.add(set);
                }
            });

            props.put("sets", sets);

            return new ApiSimpleResponse(props);
        }
    }

    public static class LookupSetForm
    {
        private String lookupSetName;
        private String lookupSetLabel;

        public String getLookupSetName()
        {
            return lookupSetName;
        }

        public void setLookupSetName(String lookupSetName)
        {
            this.lookupSetName = lookupSetName;
        }

        public String getLookupSetLabel()
        {
            return lookupSetLabel;
        }

        public void setLookupSetLabel(String lookupSetLabel)
        {
            this.lookupSetLabel = lookupSetLabel;
        }
    }

    @RequiresPermission(AdminPermission.class)
    public class GetLookupSetValuesAction extends ReadOnlyApiAction<LookupSetForm>
    {
        public ApiResponse execute(LookupSetForm form, BindException errors)
        {
            if (form.getLookupSetName() == null)
            {
                return null;
            }
            SQLFragment sql = new SQLFragment("SELECT rowid, value, title, description, set_name, category FROM ");
            sql.append(SNPRC_EHRSchema.getInstance().getTableInfoLookupValues());
            sql.append(" WHERE set_name = ?");
            sql.addAll((String) form.getLookupSetName());
            List<JSONObject> values = new ArrayList<JSONObject>();
            Map<String, Object> props = new HashMap<String, Object>();

            new SqlSelector(SNPRC_EHRSchema.getInstance().getSchema(), sql).forEach(new ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet rs) throws SQLException
                {
                    JSONObject value = new JSONObject();

                    value.put("rowid", rs.getString("rowid"));
                    value.put("value", rs.getString("value"));
                    value.put("title", rs.getString("title"));
                    value.put("description", rs.getString("description"));
                    value.put("set_name", rs.getString("set_name"));
                    value.put("category", rs.getString("category"));

                    values.add(value);
                }
            });

            props.put("values", values);

            return new ApiSimpleResponse(props);
        }
    }

    @RequiresPermission(AdminPermission.class)
    public class UpdateLookupSetValuesAction extends MutatingApiAction<SimpleApiJsonForm>
    {
        @Override
        public ApiResponse execute(SimpleApiJsonForm simpleApiJsonForm, BindException errors)
        {
            Map<String, Object> props = new HashMap<String, Object>();
            JSONObject json;
            JSONArray rows;
            try
            {
                json = simpleApiJsonForm.getJsonObject();
                rows = (JSONArray) json.get("values");
            }
            catch (Exception exp)
            {
                json = simpleApiJsonForm.getJsonObject();
                rows = new JSONArray();
                rows.put(0, (JSONObject) json.get("values"));
            }
            TableInfo table = SNPRC_EHRSchema.getInstance().getTableInfoLookupValues();
            try (DbScope.Transaction transaction = SNPRC_EHRSchema.getInstance().getSchema().getScope().ensureTransaction())
            {
                for (int i = 0; i < rows.length(); i++)
                {
                    JSONObject o = rows.getJSONObject(i);
                    if (o.get("value") == null || o.getString("value").length() == 0)
                    {
                        continue;
                    }


                    if (o.get("rowid") != null && o.getInt("rowid") != 0)
                    {

                        Table.update(getUser(), table, o, o.getInt("rowid"));

                    }
                    else
                    {
                        o.put("container", this.getContainer().getId());
                        o.put("createdBy", this.getUser().getUserId());
                        o.put("created", new Date());
                        Table.insert(getUser(), table, o);

                    }
                }

                props.put("success", true);
                transaction.commit();
            }
            catch (Exception e)
            {
                props.put("success", false);
                errors.reject("ERROR", e.getMessage());
            }
            return new ApiSimpleResponse(props);
        }
    }

    @RequiresPermission(AdminPermission.class)
    public class DeleteLookupSetValuesAction extends MutatingApiAction<SimpleApiJsonForm>
    {
        @Override
        public ApiResponse execute(SimpleApiJsonForm simpleApiJsonForm, BindException errors)
        {
            Map<String, Object> props = new HashMap<String, Object>();


            TableInfo lookupValuesTable = SNPRC_EHRSchema.getInstance().getTableInfoLookupValues();

            try
            {
                JSONObject json = (JSONObject) simpleApiJsonForm.getJsonObject().get("values");
                Table.delete(lookupValuesTable, json.getInt("rowid"));
                props.put("success", true);
            }
            catch (Exception ex)
            {
                props.put("success", false);
                props.put("message", ex.getMessage());
            }

            return new ApiSimpleResponse(props);
        }
    }


    @RequiresPermission(AdminPermission.class)
    public class UpdateLookupSetAction extends MutatingApiAction<LookupSetForm>
    {
        @Override
        public ApiResponse execute(LookupSetForm lookupSetForm, BindException errors)
        {
            Map<String, Object> props = new HashMap<String, Object>();


            TableInfo lookupSetsTable = SNPRC_EHRSchema.getInstance().getTableInfoLookupSets();

            if (lookupSetForm.getLookupSetName() != null && !lookupSetForm.getLookupSetName().isEmpty())
            {
                //update

                int ret = new SqlExecutor(DbSchema.get("ehr_lookups")).execute(
                        "UPDATE " + lookupSetsTable + " SET label=? WHERE setname=?", lookupSetForm.getLookupSetLabel(), lookupSetForm.getLookupSetName());

                if (ret == 0)
                {
                    props.put("success", false);
                }
                else
                {
                    props.put("success", true);
                }
            }
            else
            {
                //add new
                Map newSet = new HashMap();
                newSet.put("label", lookupSetForm.getLookupSetLabel());
                newSet.put("setname", lookupSetForm.getLookupSetLabel().trim().replaceAll(" ", "_"));
                newSet.put("keyField", "value");
                newSet.put("titleColumn", "description");
                newSet.put("container", this.getContainer().getId());
                try
                {
                    Table.insert(this.getUser(), lookupSetsTable, newSet);
                    props.put("success", true);
                }
                catch (Exception ex)
                {
                    props.put("success", false);
                }

            }

            return new ApiSimpleResponse(props);
        }
    }


    @RequiresPermission(AdminPermission.class)
    public class DeleteLookupSetAction extends MutatingApiAction<LookupSetForm>
    {
        @Override
        public ApiResponse execute(LookupSetForm lookupSetForm, BindException errors)
        {
            Map<String, Object> props = new HashMap<String, Object>();


            TableInfo lookupSetsTable = SNPRC_EHRSchema.getInstance().getTableInfoLookupSets();
            TableInfo lookupValuesTable = SNPRC_EHRSchema.getInstance().getTableInfoLookupValues();

            if (lookupSetForm.getLookupSetName() != null && !lookupSetForm.getLookupSetName().isEmpty())
            {
                //DELETE

                new SqlExecutor(DbSchema.get("ehr_lookups")).execute(
                        "DELETE FROM " + lookupValuesTable + " WHERE set_name=?", lookupSetForm.getLookupSetName());

                new SqlExecutor(DbSchema.get("ehr_lookups")).execute("DELETE FROM " + lookupSetsTable + " WHERE setname=?", lookupSetForm.getLookupSetName());

                props.put("success", true);

            }
            else
            {
                props.put("success", false);
            }

            return new ApiSimpleResponse(props);
        }
    }

}
