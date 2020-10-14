package org.labkey.snprc_scheduler.query;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.TableInfo;
import org.labkey.api.query.ExprColumn;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.SimpleQueryUpdateService;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.snprc_scheduler.SNPRC_schedulerUserSchema;
import org.labkey.snprc_scheduler.domains.TimelineItem;

import java.sql.SQLException;
import java.util.Map;

public class TimelineItemTable extends SimpleUserSchema.SimpleTable<SNPRC_schedulerUserSchema>
{

    /**
     *
     * Created by thawkins on 9/17/2018.
     * Create the simple table.
     * @param schema
     * @param table
     */

    public TimelineItemTable(SNPRC_schedulerUserSchema schema, TableInfo table, ContainerFilter cf)
    {
        super(schema, table, cf);
    }

    @Override
    public SimpleUserSchema.SimpleTable init()
    {
        super.init();

        SQLFragment pkgIdSql = new SQLFragment();

        pkgIdSql.append("(SELECT p.PkgId as PkgId FROM snd.ProjectItems as pi");
        pkgIdSql.append(" JOIN snd.SuperPkgs as sp ON pi.SuperPkgId = sp.SuperPkgId");
        pkgIdSql.append(" JOIN snd.Pkgs AS p ON p.PkgId = sp.PkgId");
        pkgIdSql.append(" WHERE " + ExprColumn.STR_TABLE_ALIAS + ".ProjectItemId = pi.ProjectItemId )");
        ExprColumn pkgIdCol = new ExprColumn(this, TimelineItem.TIMELINEITEM_PKG_ID, pkgIdSql, JdbcType.INTEGER);
        addColumn(pkgIdCol);

        return this;
    }

    @Override
    public QueryUpdateService getUpdateService()
    {
        return new TimelineItemTable.UpdateService(this);
    }

    protected class UpdateService extends SimpleQueryUpdateService
    {
        public UpdateService(SimpleUserSchema.SimpleTable ti)
        {
            super(ti, ti.getRealTable());
        }


        @Override
        protected Map<String, Object> deleteRow(User user, Container container, Map<String, Object> oldRowMap) throws QueryUpdateServiceException, SQLException, InvalidKeyException
        {

            //we will need the timelineItemId if we want to do something with the row before deleting it
            //int timelineItemId = (Integer) oldRowMap.get(TimelineItem.TIMELINEITEM_TIMELINE_ID);

            return super.deleteRow(user, container, oldRowMap);
        }

        private TableInfo getTableInfo(@NotNull UserSchema schema, @NotNull String table, ContainerFilter cf)
        {
            TableInfo tableInfo = schema.getTable(table, cf);
            if (tableInfo == null)
                throw new IllegalStateException("TableInfo not found for: " + table);

            return tableInfo;
        }

        private QueryUpdateService getQueryUpdateService(@NotNull TableInfo table)
        {
            QueryUpdateService qus = table.getUpdateService();
            if (qus == null)
                throw new IllegalStateException(table.getName() + " query update service");

            return qus;
        }
    }
}
