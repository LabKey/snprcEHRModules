package org.labkey.snprc_scheduler.security;

import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.CoreSchema;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.FieldKey;
import org.labkey.api.security.User;

import java.util.Collections;
import java.util.Set;

/**
 * Created by thawkins on 11/2/2018.
 */


public enum QCStateEnum
{
    // modeled after SND QCStates
    COMPLETED("Completed", "Record has been completed and is public", true),
    REJECTED("Rejected", "Record has been reviewed and rejected", false),
    REVIEW_REQUIRED("Review Required", "Review is required prior to public release", false),
    IN_PROGRESS("In Progress", "Draft Record, not public", false);

    private String _name;
    private String _description;
    private boolean _publicData;

    QCStateEnum(String name, String description, boolean publicData)
    {
        _name = name;
        _description = description;
        _publicData = publicData;
    }

    public String getName()
    {
        return _name;
    }

    public void setName(String name)
    {
        _name = name;
    }

    public String getDescription()
    {
        return _description;
    }

    public void setDescription(String description)
    {
        _description = description;
    }

    public boolean isPublicData()
    {
        return _publicData;
    }

    public void setPublicData(boolean publicData)
    {
        _publicData = publicData;
    }

    public static Integer getQCStateEnumId(Container c, User u, QCStateEnum qcStateEnum)
    {
        if (qcStateEnum == null) { return null; }
        TableInfo qcStateTable = CoreSchema.getInstance().getTableInfoDataStates();
        SimpleFilter qcFilter = SimpleFilter.createContainerFilter(c).addCondition(FieldKey.fromParts("Label"), qcStateEnum.getName(), CompareType.EQUAL);
        Set<String> cols = Collections.singleton("RowId");
        TableSelector qcStateTs = new TableSelector(qcStateTable, cols, qcFilter, null);
        return qcStateTs.getObject(Integer.class);
    }
    public static QCStateEnum getQCStateEnumById(Container c, User u, int qcStateId)
    {
        TableInfo qcStateTable = CoreSchema.getInstance().getTableInfoDataStates();
        SimpleFilter qcFilter = SimpleFilter.createContainerFilter(c).addCondition(FieldKey.fromParts("RowId"), qcStateId, CompareType.EQUAL);
        Set<String> cols = Collections.singleton("Label");
        TableSelector qcStateTs = new TableSelector(qcStateTable, cols, qcFilter, null);
        String qcStateName = qcStateTs.getObject(String.class);
        return QCStateEnum.getQCStateEnumByName(qcStateName);
    }

    @Nullable
    public static QCStateEnum getQCStateEnumByName(String name)
    {
        for (QCStateEnum qcStateEnum : QCStateEnum.values())
        {
            if (qcStateEnum.getName().equalsIgnoreCase(name))
            {
                return qcStateEnum;
            }
        }
        return null;
    }

}
