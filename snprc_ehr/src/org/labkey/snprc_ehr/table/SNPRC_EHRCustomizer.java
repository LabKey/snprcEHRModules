package org.labkey.snprc_ehr.table;

import org.apache.log4j.Logger;
import org.labkey.api.data.AbstractTableInfo;
import org.labkey.api.data.ColumnInfo;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.WrappedColumn;
import org.labkey.api.ldk.table.AbstractTableCustomizer;
import org.labkey.api.query.QueryForeignKey;
import org.labkey.api.query.UserSchema;
import org.labkey.api.study.DataSetTable;

/**
 * Created by bimber on 1/23/2015.
 */
public class SNPRC_EHRCustomizer extends AbstractTableCustomizer
{
    private static final Logger _log = Logger.getLogger(SNPRC_EHRCustomizer.class);

    public SNPRC_EHRCustomizer()
    {

    }

    public void customize(TableInfo table)
    {
        if (table instanceof AbstractTableInfo)
        {
            doSharedCustomization((AbstractTableInfo) table);
            doTableSpecificCustomizations((AbstractTableInfo) table);
        }
    }

    /**
     * This should contain java code that will act upon any table in the EHR, which includes
     * core ehr and ehr_lookups schema, study datasets, etc.
     *
     * This gives you the opportunity to apply standardized configuration across all tables that
     * use this customizer, which can be more efficient than editing each XML file.
     *
     * It also gives the opportunity to make conditional changes, such as only adding a URL if the user has
     * specific permissions.
     *
     * Finally, you can add calculated columns, such as SQL expressions.  This can be very useful, as the LK API typically
     * only lets you act on single columns.  An example could be a column created by concatenating 2 columns (ie. drug amount + units in a single col),
     * or coalescing a series of columns (preferentially displaying col 1, but showing col 2 if null)
     */
    public void doSharedCustomization(AbstractTableInfo ti)
    {
        /*
            ColumnInfo projectCol = ti.getColumn("project");
            if (projectCol != null)
            {
                projectCol.setLabel("I changed the label!");
            }

         */
    }

    /**
     * Allows changes to be applied table-by-table
     */
    public void doTableSpecificCustomizations(AbstractTableInfo ti)
    {
        /*
            if (matches(ti, "study", "Lab Results"))
            {
                customizeLabResults(ti);
            }
         */
        if (matches(ti, "study", "Animal"))
        {
            customizeAnimalTable((AbstractTableInfo) ti);
        }    
    }

    /**
     * A helper that will do a case-insensitive, name-vs-label-aware match to determine if the
     * TableInfo corresponds to schemaName/queryName provided.
     */
    protected boolean matches(TableInfo ti, String schema, String query)
    {
        if (ti instanceof DataSetTable)
            return ti.getSchema().getName().equalsIgnoreCase(schema) && (ti.getName().equalsIgnoreCase(query) || ti.getTitle().equalsIgnoreCase(query));
        else
            return ti.getSchema().getName().equalsIgnoreCase(schema) && ti.getName().equalsIgnoreCase(query);
    }

    private void customizeAnimalTable(AbstractTableInfo ds)
    {
        UserSchema us = getUserSchema(ds, "study");
        if (us == null)
        {
            return;
        }

        if (ds.getColumn("parents") == null)
        {
            ColumnInfo col = getWrappedCol(us, ds, "parents", "demographicsParents", "Id", "Id");
            col.setLabel("Parents");
            ds.addColumn(col);
        }

        if (ds.getColumn("totalOffspring") == null)
        {
            ColumnInfo col15 = getWrappedCol(us, ds, "totalOffspring", "demographicsTotalOffspring", "Id", "Id");
            col15.setLabel("Number of Offspring");
            col15.setDescription("Shows the total offspring of each animal");
            ds.addColumn(col15);
        }
    }

    private ColumnInfo getWrappedCol(UserSchema us, AbstractTableInfo ds, String name, String queryName, String colName, String targetCol)
    {

        WrappedColumn col = new WrappedColumn(ds.getColumn(colName), name);
        col.setReadOnly(true);
        col.setIsUnselectable(true);
        col.setUserEditable(false);
        col.setFk(new QueryForeignKey(us, null, queryName, targetCol, targetCol));

        return col;
    }

}