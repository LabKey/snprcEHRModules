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
package org.labkey.snprc_ehr.helpers;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.JSONObject;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.query.FieldKey;

import java.io.IOException;

/**
 * Created by lkacimi on 4/14/2017.
 */
public class SortFilterHelper
{
    /**
     * @param sortBy       a json string of the form [{property:'columnName',direction:'ASC/DESC'},....]
     * @param toUnderScore whether the column should be replaced by its underscore variant or not (fooBar---->foo_bar)
     * @return sort clause
     */
    public static Sort getSort(String sortBy, boolean toUnderScore)
    {
        ObjectMapper mapper = new ObjectMapper();
        Sort sort = new Sort();
        if (sortBy == null || sortBy.equals(""))
        {
            return sort;
        }
        try
        {
            JSONObject[] jsonObjects = mapper.readValue(sortBy, JSONObject[].class);
            for (JSONObject sortObject : jsonObjects)
            {

                if (sortObject.has("property") && sortObject.has("direction"))
                {
                    String column = (String) sortObject.get("property");
                    if (toUnderScore)
                    {
                        String[] columnParts = column.split("(?=\\p{Upper})");
                        column = String.join("_", columnParts).toLowerCase();
                    }
                    switch (((String) sortObject.get("direction")).toUpperCase())
                    {
                        case "ASC":
                            sort.appendSortColumn(FieldKey.fromString(column), Sort.SortDirection.ASC, false);
                            break;
                        case "DESC":
                            sort.appendSortColumn(FieldKey.fromString(column), Sort.SortDirection.DESC, false);
                            break;
                    }
                }
            }

            return sort;
        }
        catch (IOException e)
        {
            return sort;
        }


    }

    /**
     * @param filterBy json string of the form [{"property":"columnName","value":"foo"}]
     * @return
     */
    public static SimpleFilter getFilter(String filterBy)
    {
        ObjectMapper mapper = new ObjectMapper();
        SimpleFilter filter = new SimpleFilter();
        if (filterBy == null || filterBy.equals(""))
        {
            return filter;
        }
        try
        {
            JSONObject[] jsonObjects = mapper.readValue(filterBy, JSONObject[].class);
            for (JSONObject filterObject : jsonObjects)
            {
                if (filterObject.has("property") && filterObject.has("value") && filterObject.get("value") != null && !((String) filterObject.get("value")).equals(""))
                {
                    filter.addCondition(FieldKey.fromString((String) filterObject.get("property")), filterObject.get("value"), CompareType.CONTAINS);

                }
            }

            return filter;
        }
        catch (IOException e)
        {
            return filter;
        }
    }
}
