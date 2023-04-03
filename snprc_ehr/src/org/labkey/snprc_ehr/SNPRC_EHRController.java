/*
 * Copyright (c) 2014-2019 LabKey Corporation
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

import org.json.old.JSONObject;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.FormViewAction;
import org.labkey.api.action.MutatingApiAction;
import org.labkey.api.action.ReadOnlyApiAction;
import org.labkey.api.action.SimpleApiJsonForm;
import org.labkey.api.action.SimpleRedirectAction;
import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.ObjectFactory;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.security.EHRDataEntryPermission;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DetailsURL;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryAction;
import org.labkey.api.query.QueryForm;
import org.labkey.api.query.QueryParseException;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.QueryView;
import org.labkey.api.query.QueryWebPart;
import org.labkey.api.query.UserSchema;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.AdminPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.security.permissions.UpdatePermission;
import org.labkey.api.util.GUID;
import org.labkey.api.util.URLHelper;
import org.labkey.api.view.ActionURL;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.Portal;
import org.labkey.api.view.WebPartFactory;
import org.labkey.api.view.WebPartView;
import org.labkey.snprc_ehr.domain.AnimalGroup;
import org.labkey.snprc_ehr.domain.AnimalGroupCategory;
import org.labkey.snprc_ehr.domain.NewAnimalData;
import org.labkey.snprc_ehr.notification.SSRSConfigManager;
import org.labkey.snprc_ehr.security.ManageLookupTablesPermission;
import org.labkey.snprc_ehr.security.SNPRCColonyAdminPermission;
import org.labkey.snprc_ehr.services.SNPRC_EHRValidator;
import org.springframework.beans.PropertyValues;
import org.springframework.validation.BindException;
import org.springframework.validation.Errors;
import org.springframework.web.servlet.ModelAndView;

import java.net.MalformedURLException;
import java.net.URL;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SNPRC_EHRController extends SpringActionController
{
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(SNPRC_EHRController.class);
    public static final String NAME = "snprc_ehr";

    public SNPRC_EHRController()
    {
        setActionResolver(_actionResolver);
    }

    public static class SSRSConfigForm
    {
        private String _user;
        private String _password;
        private String _baseURL;

        public String getUser()
        {
            return _user;
        }

        public void setUser(String user)
        {
            _user = user;
        }

        public String getPassword()
        {
            return _password;
        }

        public void setPassword(String password)
        {
            _password = password;
        }

        public String getBaseURL()
        {
            return _baseURL;
        }

        public void setBaseURL(String baseURL)
        {
            _baseURL = baseURL;
        }
    }

    @RequiresPermission(AdminPermission.class)
    public class SSRSConfigAction extends FormViewAction<SSRSConfigForm>
    {
        @Override
        public void validateCommand(SSRSConfigForm target, Errors errors)
        {
            try
            {
                new URL(target.getBaseURL());
            }
            catch (MalformedURLException e)
            {
                errors.reject("baseURL", "Bad base URL. " + (e.getMessage() == null ? "" : e.getMessage()));
            }
        }

        @Override
        public ModelAndView getView(SSRSConfigForm form, boolean reshow, BindException errors)
        {
            if (!reshow)
            {
                form.setUser(SSRSConfigManager.getInstance().getUser(getContainer()));
                form.setPassword(SSRSConfigManager.getInstance().getPassword(getContainer()));
                form.setBaseURL(SSRSConfigManager.getInstance().getBaseURL(getContainer()));
            }
            return new JspView<>("/org/labkey/snprc_ehr/ssrsConfig.jsp", form, errors);
        }

        @Override
        public boolean handlePost(SSRSConfigForm form, BindException errors) throws Exception
        {
            SSRSConfigManager.getInstance().setProperties(getContainer(), form.getUser(), form.getPassword(), form.getBaseURL());
            return true;
        }

        @Override
        public URLHelper getSuccessURL(SSRSConfigForm ssrsConfigForm)
        {
            return new ActionURL(SNPRC_EHRController.NAME, "ehrAdmin", getContainer());
        }

        @Override
        public void addNavTrail(NavTree root)
        {
            root.addChild("SSRS Configuration");
        }
    }

    @RequiresPermission(ManageLookupTablesPermission.class)
    public class EditLookupTablesAction extends SimpleViewAction
    {

        @Override
        public void addNavTrail(NavTree root)
        {
            root.addChild("Lookup Table Admin", new ActionURL(true));
        }

        @Override
        public ModelAndView getView(Object o, BindException errors)
        {
            return new JspView<>("/org/labkey/snprc_ehr/views/EditLookupTables.jsp");
        }
    }


    @RequiresPermission(UpdatePermission.class)
    public class UpdateQueryAction extends SimpleViewAction<QueryForm>
    {
        private QueryForm _form;

        @Override
        public ModelAndView getView(QueryForm form, BindException errors) throws Exception
        {
            form.ensureQueryExists();

            _form = form;

            String schemaName = form.getSchemaName();
            String queryName = form.getQueryName();

            QueryView queryView = QueryView.create(form, errors);
            TableInfo ti = queryView.getTable();
            List<String> pks = ti.getPkColumnNames();
            String keyField = null;
            if (pks.size() == 1)
                keyField = pks.get(0);

            ActionURL url = getViewContext().getActionURL().clone();

            if (keyField != null)
            {
                DetailsURL importUrl = DetailsURL.fromString("/query/importData.view?schemaName=" + schemaName + "&query.queryName=" + queryName + "&keyField=" + keyField);
                importUrl.setContainerContext(getContainer());

                DetailsURL updateUrl = DetailsURL.fromString("/ehr/dataEntryForm.view?formType=" + queryName + "&taskid=${taskid}");
                updateUrl.setContainerContext(getContainer());

                DetailsURL deleteUrl = DetailsURL.fromString("/query/deleteQueryRows.view?schemaName=" + schemaName + "&query.queryName=" + queryName);
                deleteUrl.setContainerContext(getContainer());

                url.addParameter("importURL", importUrl.toString());
                url.addParameter("updateURL", updateUrl.toString());
                url.addParameter("deleteURL", deleteUrl.toString());
                url.addParameter("showInsertNewButton", false);
                url.addParameter("dataRegionName", "query");
            }

            url.addParameter("queryName", queryName);
            url.addParameter("allowChooseQuery", false);

            WebPartFactory factory = Portal.getPortalPartCaseInsensitive("Query");
            Portal.WebPart part = factory.createWebPart();
            part.setProperties(url.getQueryString());

            QueryWebPart qwp = new QueryWebPart(getViewContext(), part);
            qwp.setTitle(ti.getTitle());
            qwp.setFrame(WebPartView.FrameType.NONE);
            return qwp;
        }

        @Override
        public void addNavTrail(NavTree root)
        {
            TableInfo ti = null;
            try
            {
                ti = _form.getSchema() == null ? null : _form.getSchema().getTable(_form.getQueryName());
            }
            catch (QueryParseException x)
            {
                /* */
            }

            root.addChild(ti == null ? _form.getQueryName() : ti.getTitle(), _form.urlFor(QueryAction.executeQuery));
        }
    }

    // http://localhost:8080/labkey/snprc_ehr/snprc/getNextAnimalId
    @RequiresPermission(EHRDataEntryPermission.class)
    public class getNextAnimalIdAction extends MutatingApiAction<SimpleApiJsonForm>
    {
        @Override
        public ApiResponse execute(SimpleApiJsonForm simpleApiJsonForm, BindException errors)
        {
            Map<String, Object> props = new HashMap<>();
            JSONObject json = new JSONObject();
            List<JSONObject> data = new ArrayList<>();

            try
            {
                List<Map<String, Object>> dataList = new ArrayList<>();
                int newAnimalId = SNPRC_EHRSequencer.ANIMALID.getNext(getContainer(), getUser(), false);
                if (newAnimalId > 0)
                {
                    json.put("Id", newAnimalId);

                    data.add(json);
                    props.put("success", true);
                    props.put("rows", data);
                }
                else
                {
                    props.put("success", false);
                    props.put("message", "Id Sequencer error");
                }
            }
            catch (Exception e)
            {
                props.put("success", false);
                props.put("message", e.getMessage());
            }
            return new ApiSimpleResponse(props);
        }
    }

    @RequiresPermission(SNPRCColonyAdminPermission.class)
    public class BirthReportAction extends SimpleRedirectAction
    {
        @Override
        public URLHelper getRedirectURL(Object o)
        {
            return new ActionURL(NAME, "BirthRecordReport", getContainer());
        }
    }

    @RequiresPermission(SNPRCColonyAdminPermission.class)
    public class SsrsReportsAction extends SimpleRedirectAction
    {
        @Override
        public URLHelper getRedirectURL(Object o)
        {
            return new ActionURL(NAME, "SsrsReporting", getContainer());
        }
    }

    @RequiresPermission(ReadPermission.class)
    public class IdChipReaderAction extends SimpleRedirectAction
    {
        @Override
        public URLHelper getRedirectURL(Object o)
        {
            return new ActionURL(NAME, "ChipReader", getContainer());
        }
    }

    @RequiresPermission(EHRDataEntryPermission.class)
    public class SndEventViewAction extends SimpleRedirectAction
    {
        @Override
        public URLHelper getRedirectURL(Object o)
        {
            return new ActionURL(NAME, "SndEventsViewer", getContainer());
        }
    }

    @RequiresPermission(ManageLookupTablesPermission.class)
    public class SndLookupsAction extends SimpleRedirectAction {
        @Override
        public URLHelper getRedirectURL(Object o) { return new ActionURL(NAME, "SndLookupsManagement", getContainer()); }
    }

    @RequiresPermission(SNPRCColonyAdminPermission.class)
    public class NewAnimalWizardAction extends SimpleRedirectAction
    {
        @Override
        public URLHelper getRedirectURL(Object o)
        {
            return new ActionURL(NAME, "NewAnimalPage", getContainer());
        }
    }

    /**
     * Get all New Animals
     */
    @RequiresPermission(SNPRCColonyAdminPermission.class)
    public class GetNewAnimalDataAction extends ReadOnlyApiAction<NewAnimalData>
    {
        @Override
        public ApiResponse execute(NewAnimalData o, BindException errors)
        {

            Map<String, Object> props = new HashMap<String, Object>();


            SimpleFilter filter = new SimpleFilter();
            filter.addCondition(FieldKey.fromString("Id"), 1, CompareType.GTE);

            UserSchema us = new SNPRC_EHRUserSchema(getUser(), getContainer());
            TableInfo ti = us.getTable("NewAnimalData", null, true, false);
            ArrayList<NewAnimalData> rows = new TableSelector(ti, filter, null).getArrayList(NewAnimalData.class);

            List<JSONObject> jsonRows = new ArrayList<>();
            for (NewAnimalData form : rows)
            {
                jsonRows.add(form.toJSON(getContainer(), getUser()));
            }

            props.put("rows", jsonRows);

            return new ApiSimpleResponse(props);
        }
    }

    /**
     * Update/Add new animal
     */
    @RequiresPermission(SNPRCColonyAdminPermission.class)
    public class UpdateAnimalDataAction extends MutatingApiAction<NewAnimalData>
    {
        @Override
        public void validateForm(NewAnimalData newAnimalData, Errors errors)
        {

            if (newAnimalData == null)
            {
                errors.reject(ERROR_MSG, "Missing json parameter.");
                return;
            }
            try {
                SNPRC_EHRValidator.validateNewAnimalData(getContainer(), getUser(), newAnimalData);
            }
            catch (ValidationException e) {
                errors.reject(ERROR_MSG, e.getMessage());
            }

            return;
        }

        @Override
        public ApiResponse execute(NewAnimalData newAnimalData, BindException errors)
        {
            boolean isMultipleSequenceRequest = false;
            Map<String, Object> props = new HashMap<>();

            PropertyValues pv = getPropertyValues();
            if (!pv.isEmpty())
            {
                String property = (pv.getPropertyValue("isMultipleSequenceRequest").getValue() != null) ?
                    pv.getPropertyValue("isMultipleSequenceRequest").getValue().toString() : "";

                isMultipleSequenceRequest = Boolean.parseBoolean(property);
            }

            try (DbScope.Transaction transaction = SNPRC_EHRSchema.getInstance().getSchema().getScope().ensureTransaction())
            {
                Map<String, Object> primaryKey = new HashMap<>();
                List<Map<String, Object>> pk = new ArrayList<>();
                List<Map<String, Object>> rowsList = new ArrayList<>();
                UserSchema us = new SNPRC_EHRUserSchema(getUser(), getContainer());
                ObjectFactory<NewAnimalData> factory = ObjectFactory.Registry.getFactory(NewAnimalData.class);

                TableInfo table = us.getTable("NewAnimalData", null, false, true);
                if (table == null) throw new SQLException("SNPRC_EHRController: TableInfo is null");
                QueryUpdateService qus = table.getUpdateService();
                if (qus == null) throw new SQLException("SNPRC_EHRController: Query update service is null");
                BatchValidationException batchErrors = new BatchValidationException();

                if (newAnimalData.getId() != null)
                {
                    Map<String, Object> dataAsMap = factory.toMap(newAnimalData, null);

                    dataAsMap.put(NewAnimalData.NEWANIMAL_CONTAINER, this.getContainer().getId());
                    primaryKey.put(NewAnimalData.NEWANIMAL_ID, newAnimalData.getId());

                    pk.add(primaryKey);
                    rowsList.add(dataAsMap);

                    qus.updateRows(this.getUser(), getContainer(), rowsList, pk, null, null);

                }
                else
                {
                    newAnimalData.setId(SNPRC_EHRSequencer.ANIMALID.getNext(getContainer(), getUser(), isMultipleSequenceRequest).toString());
                    Map<String, Object> dataAsMap = factory.toMap(newAnimalData, null);

                    dataAsMap.put(NewAnimalData.NEWANIMAL_OBJECTID, GUID.makeGUID());
                    dataAsMap.put(NewAnimalData.NEWANIMAL_CONTAINER, this.getContainer().getId());

                    rowsList.add(dataAsMap);

                    qus.insertRows(getUser(), getContainer(), rowsList, batchErrors, null, null);
                    if (batchErrors.hasErrors()) throw batchErrors;

                    props.put(NewAnimalData.NEWANIMAL_ID, newAnimalData.getId());
                }

                props.put("success", true);
                transaction.commit();
            }
            catch (Exception e)
            {
                props.put("success", false);
                props.put("message", e.getMessage() != null ? e.getMessage() : "Error saving Data");
            }

            return new ApiSimpleResponse(props);
        }
    }

    @RequiresPermission(EHRDataEntryPermission.class)
    public class RemoveCategoryAction extends MutatingApiAction<AnimalGroupCategory>
    {
        @Override
        public ApiResponse execute(AnimalGroupCategory animalGroupCategory, BindException errors)
        {
            Map<String, Object> props = new HashMap<String, Object>();
            try
            {
                UserSchema us = new SNPRC_EHRUserSchema(getUser(), getContainer());
                TableInfo table = us.getTable("animal_groups");

                SimpleFilter filter = new SimpleFilter();
                filter.addCondition(FieldKey.fromString("category_code"), animalGroupCategory.getCategoryCode(), CompareType.EQUAL);

                List<AnimalGroup> groups = new TableSelector(table, filter, null).getArrayList(AnimalGroup.class);
                if (groups == null || groups.isEmpty())
                {
                    UserSchema cs = new SNPRC_EHRUserSchema(getUser(), getContainer());
                    TableInfo categoriesTable = cs.getTable("animal_group_categories");

                    SimpleFilter categoriesFilter = new SimpleFilter();
                    categoriesFilter.addCondition(FieldKey.fromString("category_code"), animalGroupCategory.getCategoryCode(), CompareType.EQUAL);
                    Map<String, Object> animalGroupsCategory = new TableSelector(categoriesTable, categoriesFilter, null).getObject(Map.class);

                    List<Map<String, Object>> keys = new ArrayList<Map<String, Object>>();

                    Map<String, Object> idMap = new HashMap<>();
                    idMap.put("category_code", animalGroupsCategory.get("category_code"));
                    keys.add(idMap);

                    QueryUpdateService qus = categoriesTable.getUpdateService();
                    try
                    {
                        qus.deleteRows(getUser(), getContainer(), keys, null, null);
                        props.put("success", true);
                        return new ApiSimpleResponse(props);
                    }
                    catch (InvalidKeyException | BatchValidationException | QueryUpdateServiceException | SQLException e)
                    {
                        props.put("success", false);
                        props.put("message", e.getMessage());
                        return new ApiSimpleResponse(props);
                    }
                }
                else
                {

                    props.put("success", false);
                    props.put("message", "Unable to delete this category, Please delete this category groups first");
                }
            }
            catch (Exception e)
            {
                props.put("success", false);
                props.put("message", e.getMessage());
            }
            return new ApiSimpleResponse(props);
        }
    }


}
