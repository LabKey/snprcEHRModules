package org.labkey.snprc_ehr.history;

import org.labkey.api.data.Container;
import org.labkey.api.data.Results;
import org.labkey.api.ehr.history.AbstractDataSource;
import org.labkey.api.module.Module;

import java.sql.SQLException;

/**
 * Created by Marty on 12/8/2016.
 */

// Place holder for clinical observations after schema restructure.
public class DefaultObservationsDataSource extends AbstractDataSource
{
    public DefaultObservationsDataSource(Module module)
    {
        super(null, null, null, null, module);
        setShowTime(false);
    }

    @Override
    protected String getHtml(Container c, Results rs, boolean redacted) throws SQLException
    {
        return null;
    }
}
