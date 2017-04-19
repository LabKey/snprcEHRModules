package org.labkey.snprc_ehr.controllers;

import org.json.JSONObject;
import org.labkey.api.action.ApiAction;
import org.labkey.api.action.ApiResponse;
import org.labkey.api.action.ApiSimpleResponse;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.ObjectFactory;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.SqlSelector;
import org.labkey.api.data.Table;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.util.GUID;
import org.labkey.snprc_ehr.SNPRC_EHRSchema;
import org.labkey.snprc_ehr.domain.Institution;
import org.labkey.snprc_ehr.helpers.SortFilterHelper;
import org.labkey.snprc_ehr.security.ManageRelatedTablesPermission;
import org.labkey.snprc_ehr.services.StatesService;
import org.springframework.validation.BindException;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by lkacimi on 4/13/2017.
 */
public class InstitutionsController extends SpringActionController
{
    public static final String NAME = "ValidInstitutions";
    private static final DefaultActionResolver _actionResolver = new DefaultActionResolver(InstitutionsController.class);

    public InstitutionsController()
    {
        setActionResolver(_actionResolver);
    }


    @RequiresPermission(ReadPermission.class)
    public class GetInstitutionsAction extends ApiAction<Institution>
    {
        @Override
        public ApiResponse execute(Institution institution, BindException errors)
        {

            Map<String, Object> props = new HashMap<String, Object>();
            Sort sort = SortFilterHelper.getSort(institution.getSort(), true);

            SimpleFilter filter = SortFilterHelper.getFilter(institution.getFilter());

            ArrayList<Institution> rows = new TableSelector(SNPRC_EHRSchema.getInstance().getTableInfoValidInstitutions(), filter, sort).getArrayList(Institution.class);

            List<JSONObject> jsonRows = new ArrayList<>();
            for (Institution form : rows)
            {
                jsonRows.add(form.toJSON());
            }

            props.put("institutions", jsonRows);

            return new ApiSimpleResponse(props);
        }
    }


    @RequiresPermission(ReadPermission.class)
    public class GetStatesAction extends ApiAction<Object>
    {
        @Override
        public ApiResponse execute(Object o, BindException errors) throws Exception
        {

            Map<String, Object> props = new HashMap<String, Object>();
            StatesService statesService = new StatesService();
            props.put("states", statesService.getStates());

            return new ApiSimpleResponse(props);
        }
    }

    @RequiresPermission(ManageRelatedTablesPermission.class)
    public class UpdateInstitutionAction extends ApiAction<Institution>
    {


        public ApiResponse execute(Institution institution, BindException errors)
        {
            Map<String, Object> props = new HashMap<String, Object>();
            ObjectFactory factory = ObjectFactory.Registry.getFactory(Institution.class);

            try (DbScope.Transaction transaction = SNPRC_EHRSchema.getInstance().getSchema().getScope().ensureTransaction())
            {

                if (institution.getInstitutionId() != 0)
                {


                    //update
                    Map institutionAsMap = factory.toMap(institution, null);
                    institutionAsMap.put("modified", new Date());
                    institutionAsMap.put("modifiedBy", this.getUser().getUserId());


                    TableInfo institutionTable = SNPRC_EHRSchema.getInstance().getTableInfoValidInstitutions();
                    Table.update(this.getUser(), institutionTable, institutionAsMap, institution.getInstitutionId());
                    props.put("success", true);
                    transaction.commit();
                }
                else
                {
                    //insert
                    //1. get next available institution id
                    institution.setInstitutionId(this.getNextInstitutionId());
                    //1. convert institution bean to a map
                    Map institutionAsMap = factory.toMap(institution, null);
                    //2. add required keys (objectId, ...etc)
                    institutionAsMap.put("objectid", new GUID().toString().toUpperCase());
                    institutionAsMap.put("container", this.getContainer().getEntityId());
                    institutionAsMap.put("created", new Date());
                    institutionAsMap.put("createdBy", this.getUser().getUserId());
                    //3. issue an insert
                    TableInfo institutionTable = SNPRC_EHRSchema.getInstance().getTableInfoValidInstitutions();
                    Table.insert(this.getUser(), institutionTable, institutionAsMap);
                    props.put("institutionId", institution.getInstitutionId());
                    props.put("success", true);
                    transaction.commit();

                }
            }
            catch (Exception e)
            {
                props.put("success", false);
                props.put("message", e.getMessage());
            }

            return new ApiSimpleResponse(props);
        }

        public Integer getNextInstitutionId()
        {

            SQLFragment sql = new SQLFragment("SELECT MAX(institution_id) AS MAX_INSTITUTION_ID FROM ");
            sql.append(SNPRC_EHRSchema.getInstance().getTableInfoValidInstitutions());
            SqlSelector sqlSelector = new SqlSelector(SNPRC_EHRSchema.getInstance().getSchema(), sql);

            return sqlSelector.getObject(Integer.class) + 1;
        }
    }

    @RequiresPermission(ManageRelatedTablesPermission.class)
    public class DeleteInstitutionAction extends ApiAction<Institution>
    {


        public ApiResponse execute(Institution institution, BindException errors)
        {
            Map<String, Object> props = new HashMap<String, Object>();

            if (institution.getInstitutionId() != 0)
            {
                //Delete
                TableInfo institutionTable = SNPRC_EHRSchema.getInstance().getTableInfoValidInstitutions();
                SimpleFilter institutionFilter = new SimpleFilter();
                institutionFilter.addCondition(FieldKey.fromString("institution_id"), institution.getInstitutionId(), CompareType.EQUAL);
                Table.delete(institutionTable, institutionFilter);
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
