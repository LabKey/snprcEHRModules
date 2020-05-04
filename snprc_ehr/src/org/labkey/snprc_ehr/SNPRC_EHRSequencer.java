package org.labkey.snprc_ehr;

import org.labkey.api.data.Container;
import org.labkey.api.data.DbSequence;
import org.labkey.api.data.DbSequenceManager;


public enum SNPRC_EHRSequencer
{
    ANIMALID ("org.labkey.snprc_ehr.domain.AnimalId", 100);

    private String sequenceName;
    private int minId;

    SNPRC_EHRSequencer(String name, int id)
    {
        sequenceName = name;
        minId = id;
    }

    private Integer generateId(Container c)
    {
        DbSequence sequence = DbSequenceManager.get(c, sequenceName);
        sequence.ensureMinimum(minId);
        return Math.toIntExact(sequence.next());
    }

    public Integer getNext(Container c)
    {
       return generateId(c);
    }

    public Integer previewNext(Container c)
    {
        DbSequence sequence = DbSequenceManager.get(c, sequenceName);
        return  Math.toIntExact(sequence.current() + 1);
    }
}
