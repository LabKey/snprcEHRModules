package org.labkey.snprc_scheduler;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.Container;
import org.labkey.api.data.ContainerManager.ContainerListener;
import org.labkey.api.data.SQLFragment;
import org.labkey.api.data.SqlExecutor;
import org.labkey.api.security.User;
import java.util.Collections;
import java.util.Collection;

import java.beans.PropertyChangeEvent;

public class SNPRC_schedulerContainerListener implements ContainerListener
{
    @Override
    public void containerCreated(Container c, User user)
    {
    }

    @Override
    public void containerDeleted(Container c, User user)
    {
        SqlExecutor executor = new SqlExecutor(SNPRC_schedulerSchema.getInstance().getSchema());
        // Order matters: StudyDayNotes first (td_TimelineItem trigger blocks deletes otherwise),
        // then TimelineItem/AnimalJunction/ProjectItem children, then Timeline last. Timeline scope
        // is inferred by joining to snd.projects.Container since scheduler tables have no Container column.
        executor.execute(deleteByContainer("StudyDayNotes", c));
        executor.execute(deleteByContainer("TimelineItem", c));
        executor.execute(deleteByContainer("TimelineAnimalJunction", c));
        executor.execute(deleteByContainer("TimelineProjectItem", c));
        executor.execute(deleteTimelineByContainer(c));
    }

    private SQLFragment deleteByContainer(String childTable, Container c)
    {
        return new SQLFragment(
                "DELETE FROM snprc_scheduler." + childTable + " WHERE TimelineObjectId IN (" +
                        "SELECT t.ObjectId FROM snprc_scheduler.Timeline t " +
                        "JOIN snd.projects p ON p.ObjectId = t.ProjectObjectId " +
                        "WHERE p.Container = ?)", c.getId());
    }

    private SQLFragment deleteTimelineByContainer(Container c)
    {
        return new SQLFragment(
                "DELETE FROM snprc_scheduler.Timeline WHERE ObjectId IN (" +
                        "SELECT t.ObjectId FROM snprc_scheduler.Timeline t " +
                        "JOIN snd.projects p ON p.ObjectId = t.ProjectObjectId " +
                        "WHERE p.Container = ?)", c.getId());
    }

    @Override
    public void propertyChange(PropertyChangeEvent evt)
    {
    }

    @Override
    public void containerMoved(Container c, Container oldParent, User user)
    {
    }

    @NotNull @Override
    public Collection<String> canMove(Container c, Container newParent, User user)
    {
        return Collections.emptyList();
    }
}