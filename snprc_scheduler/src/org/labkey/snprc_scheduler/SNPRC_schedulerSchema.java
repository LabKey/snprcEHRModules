package org.labkey.snprc_scheduler;

import org.labkey.api.data.DbSchema;
import org.labkey.api.data.DbSchemaType;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.dialect.SqlDialect;

public class SNPRC_schedulerSchema
{

    public static final SNPRC_schedulerSchema _instance = new SNPRC_schedulerSchema();
    public static final String NAME = "snprc_scheduler";
    public static final String TABLE_NAME_TIMELINE = "Timeline";
    public static final String TABLE_NAME_TIMELINE_ITEM = "TimelineItem";
    public static final String TABLE_NAME_TIMELINE_PROJECT_ITEM = "TimelineProjectItem";
    public static final String TABLE_NAME_TIMELINE_ANIMAL_JUNCTION = "TimelineAnimalJunction";
    public static final String TABLE_NAME_STUDY_DAY_NOTES = "StudyDayNotes";

    public static SNPRC_schedulerSchema getInstance()
    {
        return _instance;
    }

    private SNPRC_schedulerSchema()
    {
        // private constructor to prevent instantiation from
        // outside this class: this singleton should only be
        // accessed via org.labkey.snprc_scheduler.SNPRC_schedulerSchema.getInstance()
    }

    public DbSchema getSchema()
    {
        return DbSchema.get(NAME, DbSchemaType.Module);
    }

    public SqlDialect getSqlDialect()
    {
        return getSchema().getSqlDialect();
    }

    public TableInfo getTableInfoTimeline()
    {
        return getSchema().getTable(TABLE_NAME_TIMELINE);
    }

    public TableInfo getTableInfoTimelineItem()
    {
        return getSchema().getTable(TABLE_NAME_TIMELINE_ITEM);
    }

    public TableInfo getTableInfoTimelineProjectItem()
    {
        return getSchema().getTable(TABLE_NAME_TIMELINE_PROJECT_ITEM);
    }

    public TableInfo getTableInfoTimelineAnimalJunction()
    {
        return getSchema().getTable(TABLE_NAME_TIMELINE_ANIMAL_JUNCTION);
    }

    public TableInfo getTableInfoStudyDayNotes()
    {
        return getSchema().getTable(TABLE_NAME_STUDY_DAY_NOTES);
    }
}
