/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
    protected String getHtml(Container c, Results rs, boolean redacted)
    {
        return null;
    }
}
