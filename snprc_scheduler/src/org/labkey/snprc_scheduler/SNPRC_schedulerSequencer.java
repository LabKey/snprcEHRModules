package org.labkey.snprc_scheduler;

import org.labkey.api.data.Container;
import org.labkey.api.data.DbSequence;
import org.labkey.api.data.DbSequenceManager;


public enum SNPRC_schedulerSequencer
{
    TIMELINEID ("org.labkey.snprc_scheduler.domain.Timeline", 100);

    private String sequenceName;
    private int minId;
    SNPRC_schedulerSequencer(String name, int id)
    {
        sequenceName = name;
        minId = id;
    }

    private Integer generateId(Container c)
    {
        DbSequence sequence = DbSequenceManager.get(c, sequenceName);
        sequence.ensureMinimum(minId);
        return sequence.next();
    }

    public Integer ensureId(Container container, Integer id)
    {
        if (id == null || id <= 0)
        {
            return generateId(container);
        }

        return id;
    }
}
