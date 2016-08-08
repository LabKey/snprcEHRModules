package org.labkey.snprc_ehr.demographics;

import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.data.ResultsImpl;
import org.labkey.api.data.Selector;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.Sort;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.demographics.AbstractListDemographicsProvider;
import org.labkey.api.module.Module;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.User;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * Created by thawkins on 8/5/2016.
 */
public class ActiveCasesDemographicsProvider extends AbstractListDemographicsProvider
{

    public ActiveCasesDemographicsProvider(Module module)
    {
        super(module, "study", "Cases", "activeCases");
    }

    @Override
    protected Set<FieldKey> getFieldKeys()
    {
        Set<FieldKey> keys = new HashSet<FieldKey>();
        keys.add(FieldKey.fromString("lsid"));
        keys.add(FieldKey.fromString("objectid"));
        keys.add(FieldKey.fromString("Id"));
        keys.add(FieldKey.fromString("caseid"));
        keys.add(FieldKey.fromString("date"));
        keys.add(FieldKey.fromString("enddate"));
        keys.add(FieldKey.fromString("reviewdate"));
        keys.add(FieldKey.fromString("category"));
        keys.add(FieldKey.fromString("problem"));
        keys.add(FieldKey.fromString("sdx"));
        keys.add(FieldKey.fromString("admitcomplaint"));
        keys.add(FieldKey.fromString("resolution"));
        keys.add(FieldKey.fromString("assignedvet"));
        keys.add(FieldKey.fromString("assignedvet/DisplayName"));
        keys.add(FieldKey.fromString("performedby"));
        keys.add(FieldKey.fromString("remark"));

        return keys;
    }

    @Override
    public Map<String, Map<String, Object>> getProperties(Container c, User u, Collection<String> ids)
    {
        final Map<String, Map<String, Object>> ret = new HashMap<>();
        final TableInfo ti = getTableInfo(c, u);
        final Map<FieldKey, ColumnInfo> cols = getColumns(ti);
        Sort sort = getSort();

        for (String id : ids)
        {
            SimpleFilter filter = getFilter(Collections.singleton(id));

            TableSelector ts = new TableSelector(ti, cols.values(), filter, sort);
            ts.setForDisplay(true);
//            ts.setMaxRows(3);

            ts.forEach(new Selector.ForEachBlock<ResultSet>()
            {
                @Override
                public void exec(ResultSet object) throws SQLException
                {
                    Results rs = new ResultsImpl(object, cols);

                    String id = rs.getString(FieldKey.fromString(ti.getColumn("Id").getAlias()));

                    Map<String, Object> map = ret.get(id);
                    if (map == null)
                        map = new HashMap<>();

                    processRow(rs, cols, map);

                    ret.put(id, map);
                }
            });
        }

        return ret;
    }


    @Override
    public Collection<String> getKeysToTest()
    {
        //for now, simply skip the whole provider.  because different records can be active from day to day, this makes validation tricky
        Set<String> keys = new HashSet<>(super.getKeysToTest());
        keys.remove(_propName);

        return keys;
    }

    @Override
    protected Sort getSort()
    {
        return new Sort("-date");
    }


    @Override
    protected SimpleFilter getFilter(Collection<String> ids)
    {
        SimpleFilter filter = super.getFilter(ids);
        filter.addCondition(FieldKey.fromString("enddate"),true, CompareType.ISBLANK);
        filter.addCondition(FieldKey.fromString("qcstate/publicData"), true, CompareType.EQUAL);

        return filter;
    }
}
