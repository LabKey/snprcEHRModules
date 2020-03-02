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
package org.labkey.snprc_ehr;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.beanutils.ConversionException;
import org.apache.commons.beanutils.PropertyUtils;
import org.apache.log4j.Logger;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.collections.CaseInsensitiveHashMap;
import org.labkey.api.data.BeanObjectFactory;
import org.labkey.api.data.ConvertHelper;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.util.ResultSetUtil;
import org.labkey.api.util.UnexpectedException;

import java.lang.reflect.InvocationTargetException;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Map;

/**
 * Created by lkacimi on 4/17/2017.
 */
public class SNPRCBeanFactory<K> extends BeanObjectFactory<K>
{

    private static Logger _log = Logger.getLogger(BeanObjectFactory.class);
    private Class<K> _class;


    public SNPRCBeanFactory(Class<K> clss)
    {
        super(clss);
        _class = clss;
    }

    /**
     * Maps property fooBar to key foo_bar, in preparation for CRUD operations
     *
     * @param bean
     * @param m
     * @return
     */
    @Override
    public
    @NotNull
    Map<String, Object> toMap(K bean, @Nullable Map<String, Object> m)
    {
        try
        {
            if (null == m)
                m = new CaseInsensitiveHashMap<>();

            for (String name : _readableProperties)
            {
                try
                {
                    Object value = PropertyUtils.getSimpleProperty(bean, name);
                    String[] r = name.split("(?=\\p{Upper})");
                    String nameToUnderscore = String.join("_", r).toLowerCase();
                    m.put(nameToUnderscore, value);
                }
                catch (NoSuchMethodException e)
                {
                    assert false : e;
                }
            }
        }
        catch (IllegalAccessException x)
        {
            assert false : x;
        }
        catch (InvocationTargetException x)
        {
            assert false : x;
            if (x.getTargetException() instanceof RuntimeException)
                throw (RuntimeException) x.getTargetException();
        }
        fixupMap(m, bean);
        return m;
    }

    @Override
    public K fromMap(K bean, Map<String, ?> m)
    {
        if (!(m instanceof CaseInsensitiveHashMap))
            m = new CaseInsensitiveHashMap<>(m);

        for (String prop : _writeableProperties.keySet())
        {
            Object value = null;
            try
            {
                // If the map contains the key, assuming that we should use the map's value, even if it's null.
                // Otherwise, don't set a value on the bean.
                //Also check if the bean has a writable property of the form fooBar for a column name: foo_bar

                String[] r = prop.split("(?=\\p{Upper})");
                String propToUnderscore = String.join("_", r).toLowerCase();
                if (m.containsKey(prop))
                {
                    value = m.get(prop);
                    BeanUtils.copyProperty(bean, prop, value);
                }
                if (m.containsKey(propToUnderscore))
                {
                    value = m.get(propToUnderscore);
                    BeanUtils.copyProperty(bean, propToUnderscore, value);
                }
            }
            catch (IllegalAccessException | InvocationTargetException x)
            {
                throw new UnexpectedException(x);
            }
            catch (IllegalArgumentException x)
            {
                _log.error("could not set property: " + prop + "=" + String.valueOf(value), x);
            }
        }

        this.fixupBean(bean);
        return bean;
    }

    @Override
    public ArrayList<K> handleArrayList(ResultSet rs) throws SQLException
    {
        ResultSetMetaData md = rs.getMetaData();
        int count = md.getColumnCount();
        CaseInsensitiveHashMap<String> propMap = new CaseInsensitiveHashMap<>(count * 2);
        for (String prop : _writeableProperties.keySet())
            propMap.put(prop, prop);

        String[] properties = new String[count + 1];
        for (int i = 1; i <= count; i++)
        {
            String label = md.getColumnLabel(i);

            String prop = propMap.get(label); //Map to correct casing...
            if (null != prop)
                properties[i] = prop;
            // map foo_bar to fooBar -- this will override the default (if both foo_bar and fooBar are bean properties, only fooBar will be mapped)
            String[] labelUnderscoreToUppercase = label.split("_");
            StringBuilder stringBuilder = new StringBuilder();
            int j = 0;
            for (String part : labelUnderscoreToUppercase)
            {
                if (j == 0)
                {
                    stringBuilder.append(part);
                    j++;
                    continue;
                }
                stringBuilder.append(part.substring(0, 1).toUpperCase() + part.substring(1));
            }
            prop = propMap.get(stringBuilder.toString());
            if (null != prop)
                properties[i] = prop;


        }

        ArrayList<K> list = new ArrayList<>();


        try
        {
            while (rs.next())
            {
                K bean = _class.newInstance();


                for (int i = 1; i <= count; i++)
                {
                    String prop = properties[i];
                    if (null == prop)
                        continue;

                    try
                    {
                        Object value = rs.getObject(i);
                        if (value == null)
                        {
                            continue;
                        }
                        if (value instanceof Double)
                            value = ResultSetUtil.mapDatabaseDoubleToJavaDouble((Double) value);
                        BeanUtils.copyProperty(bean, prop, value);
                    }
                    catch (ConvertHelper.ContainerConversionException e)
                    {
                        // Rethrow exception as-is
                        throw e;
                    }
                    catch (IllegalAccessException | InvocationTargetException e)
                    {
                        throw new IllegalStateException("Failed to copy property '" + prop + "' on class " + _class.getName(), e);
                    }
                    catch (ConversionException e)
                    {
                        if (!ModuleLoader.getInstance().isUpgradeInProgress() || !"No value specified".equals(e.getMessage()))
                            throw new IllegalStateException("Failed to copy property '" + prop + "' on class " + _class.getName(), e);
                    }
                }

                this.fixupBean(bean);
                list.add(bean);
            }
        }
        catch (InstantiationException | IllegalAccessException x)
        {
            assert false : "unexpected exception";
        }

        return list;
    }


}