package org.labkey.snprc_scheduler.query;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerFilter;
import org.labkey.api.data.JdbcType;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.data.WrappedColumn;
import org.labkey.api.query.ExprColumn;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryForeignKey;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.SimpleQueryUpdateService;
import org.labkey.api.query.SimpleUserSchema.SimpleTable;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.snprc_scheduler.SNPRC_schedulerSchema;
import org.labkey.snprc_scheduler.SNPRC_schedulerUserSchema;
import org.labkey.snprc_scheduler.domains.Timeline;

import java.sql.SQLException;
import java.util.Collections;
import java.util.Map;
import java.util.Set;

public class TimelineTable extends SimpleTable<SNPRC_schedulerUserSchema>
{

    /**
     * Created by thawkins on 9/13/2018.
     * <p>
     * Create the simple table.
     *
     * @param schema
     * @param table
     */

    public TimelineTable(SNPRC_schedulerUserSchema schema, TableInfo table, ContainerFilter cf)
    {
        super(schema, table ,cf);
    }

    @Override
    public SimpleTable init()
    {
        super.init();

        // initialize virtual columns here
        // HasItems = true if the timeline has timeline items assigned
        SQLFragment hasItemsSql = new SQLFragment();
        hasItemsSql.append("(CASE WHEN EXISTS (SELECT t.TimelineId FROM ");
        hasItemsSql.append(SNPRC_schedulerSchema.getInstance().getTableInfoTimeline(), "t");
        hasItemsSql.append(" JOIN ");
        hasItemsSql.append(SNPRC_schedulerSchema.getInstance().getTableInfoTimelineItem(), "ti");
        hasItemsSql.append(" ON t.ObjectId = ti.TimelineObjectId ");
        hasItemsSql.append(" WHERE " + ExprColumn.STR_TABLE_ALIAS + ".ObjectId = t.ObjectId )" );
        hasItemsSql.append(" THEN 'true' ELSE 'false' END)");
        ExprColumn hasItemsCol = new ExprColumn(this, Timeline.TIMELINE_HAS_ITEMS, hasItemsSql, JdbcType.BOOLEAN);
        addColumn(hasItemsCol);

        // isScheduled = true if the timelineItems have been scheduled
        SQLFragment isScheduledSql = new SQLFragment();
        isScheduledSql.append("(CASE WHEN EXISTS (SELECT 1 FROM ");
        isScheduledSql.append(SNPRC_schedulerSchema.getInstance().getTableInfoTimeline(), "t");
        isScheduledSql.append(" JOIN ");
        isScheduledSql.append(SNPRC_schedulerSchema.getInstance().getTableInfoTimelineItem(), "ti");
        isScheduledSql.append(" ON t.ObjectId = ti.TimelineObjectId and ti.ScheduleDate IS NOT NULL");
        isScheduledSql.append(" WHERE " + ExprColumn.STR_TABLE_ALIAS + ".ObjectId = t.ObjectId )" );
        isScheduledSql.append(" THEN 'true' ELSE 'false' END)");
        ExprColumn isScheduledCol = new ExprColumn(this, Timeline.TIMELINE_IS_SCHEDULED, isScheduledSql, JdbcType.BOOLEAN);
        addColumn(isScheduledCol);

        SQLFragment projectIdSql = new SQLFragment();
        projectIdSql.append("(SELECT pr.ProjectId FROM snd.Projects as pr");
        projectIdSql.append(" WHERE " + ExprColumn.STR_TABLE_ALIAS + ".ProjectObjectId = pr.ObjectId )");
        ExprColumn projectIdCol = new ExprColumn(this, Timeline.TIMELINE_PROJECT_ID, projectIdSql, JdbcType.INTEGER);
        addColumn(projectIdCol);

        SQLFragment revisionNumSql = new SQLFragment();
        revisionNumSql.append("(SELECT pr.RevisionNum FROM snd.Projects as pr");
        revisionNumSql.append(" WHERE " + ExprColumn.STR_TABLE_ALIAS + ".ProjectObjectId = pr.ObjectId )");
        ExprColumn revisionNumCol = new ExprColumn(this, Timeline.TIMELINE_PROJECT_REVISION_NUM, revisionNumSql, JdbcType.INTEGER);
        addColumn(revisionNumCol);

        // ToDo: Determine what inUse really means
        SQLFragment isInUseSql = new SQLFragment();
        isInUseSql.append("(SELECT 'false' as IsInUse)");
        ExprColumn isInUseCol = new ExprColumn(this, "IsInUse", isInUseSql, JdbcType.BOOLEAN);
        addColumn(isInUseCol);

        SQLFragment chargeIdSql = new SQLFragment();
        chargeIdSql.append("(SELECT pr.ReferenceId as ChargeId FROM snd.Projects as pr");
        chargeIdSql.append(" WHERE " + ExprColumn.STR_TABLE_ALIAS + ".ProjectObjectId = pr.ObjectId )");
        ExprColumn chargeIdCol = new ExprColumn(this, Timeline.TIMELINE_CHARGE_ID, chargeIdSql, JdbcType.INTEGER);
        addColumn(chargeIdCol);

        SQLFragment protocolSql = new SQLFragment();
        protocolSql.append("(SELECT coalesce(ps.protocol,'') as Protocol FROM ehr.project as ps");
        protocolSql.append(" JOIN snd.Projects as pr ON ps.project = pr.ReferenceId ");
        protocolSql.append(" WHERE " + ExprColumn.STR_TABLE_ALIAS + ".ProjectObjectId = pr.ObjectId )");
        ExprColumn protocolCol = new ExprColumn(this, Timeline.TIMELINE_PROTOCOL, protocolSql, JdbcType.VARCHAR);
        addColumn(protocolCol);

//        SQLFragment speciesSql = new SQLFragment();
//        //speciesSql.append("(SELECT coalesce(right(protocol, 2), 'ZZ') as Species FROM ehr.project as ps");
//        speciesSql.append("(SELECT ps.species as Species FROM ehr.project as ps");
//        speciesSql.append(" JOIN snd.Projects as pr ON ps.project = pr.ReferenceId ");
//        speciesSql.append(" WHERE " + ExprColumn.STR_TABLE_ALIAS + ".ProjectObjectId = pr.ObjectId )");
//        ExprColumn speciesCol = new ExprColumn(this, Timeline.TIMELINE_SPECIES, speciesSql, JdbcType.VARCHAR);
//        addColumn(speciesCol);
//
//      SQLFragment replaced with customizeTimelineTable()
        customizeTimelineTable();

        return this;
    }

// Expression columns query the underlying table; therefore they can't query extensible columns. To query the extensible
// column (species in ehr.projects) a WrappedColumn is used here instead, and the species column is added in Timeline/.qview.xml
    private void customizeTimelineTable()
    {
        String sndProject = "sndProject";
        UserSchema us =  getUserSchema();
        Container c = us.getContainer();
        User u = us.getUser();
        UserSchema sndSchema = QueryService.get().getUserSchema(u, c, "snd");

        if (getColumn(sndProject) == null)
        {

            if (sndSchema != null)
            {
                WrappedColumn wrapped = new WrappedColumn(getColumn("projectObjectId"), sndProject);
                wrapped.setLabel("sndProject");
                wrapped.setIsUnselectable(true);
                wrapped.setUserEditable(false);
                wrapped.setFk(new QueryForeignKey(QueryForeignKey.from(sndSchema, getContainerFilter())
                        .table("Projects")
                        .key("ObjectId")
                        .display("referenceId")));
                addColumn(wrapped);
            }
        }
    }

    public boolean isTimelineInUse(Integer timelineId, Integer revisionNum)
    {
        Set<String> cols = Collections.singleton("IsScheduled");
        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("TimelineId"), timelineId, CompareType.EQUAL).
            addCondition(FieldKey.fromString("RevisionNum"), revisionNum, CompareType.EQUAL);

        TableSelector ts = new TableSelector(this, cols, filter, null);
        Map<String, Object> result = ts.getMap();

        if (result == null)
            return false;
        else
            return Boolean.parseBoolean((String) result.get("IsScheduled"));
    }

    @Override
    public QueryUpdateService getUpdateService()
    {
        return new TimelineTable.UpdateService(this);
    }

    protected class UpdateService extends SimpleQueryUpdateService
    {
        public UpdateService(SimpleTable ti)
        {
            super(ti, ti.getRealTable());
        }


        @Override
        protected Map<String, Object> deleteRow(User user, Container container, Map<String, Object> oldRowMap) throws QueryUpdateServiceException, SQLException, InvalidKeyException
        {
            int timelineId = (Integer) oldRowMap.get(Timeline.TIMELINE_ID);
            int revisionNum = (Integer) oldRowMap.get(Timeline.TIMELINE_REVISION_NUM);

            // Cannot delete a timeline that is in use (it has timelineItems assigned)
            if (isTimelineInUse(timelineId, revisionNum))
                throw new QueryUpdateServiceException("Timeline is in use, cannot be deleted.");

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
