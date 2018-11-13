/*
 * Copyright (c) 2018 LabKey Corporation
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
package org.labkey.snd.query;

import org.apache.log4j.Logger;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.TableInfo;
import org.labkey.api.dataiterator.DataIteratorBuilder;
import org.labkey.api.dataiterator.DataIteratorContext;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.SimpleQueryUpdateService;
import org.labkey.api.query.SimpleUserSchema;
import org.labkey.api.security.User;
import org.labkey.api.snd.Event;
import org.labkey.api.snd.SNDService;
import org.labkey.snd.NarrativeAuditProvider;
import org.labkey.snd.SNDManager;
import org.labkey.snd.SNDSchema;
import org.labkey.snd.SNDUserSchema;
import org.labkey.snd.security.QCStateActionEnum;
import org.labkey.snd.security.SNDSecurityManager;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class EventsTable extends SimpleUserSchema.SimpleTable<SNDUserSchema>
{
    /**
     * Create the simple table.
     * SimpleTable doesn't add columns until .init() has been called to allow derived classes to fully initialize themselves before adding columns.
     *
     * @param schema
     * @param table
     */
    public EventsTable(SNDUserSchema schema, TableInfo table)
    {
        super(schema, table);
    }

    @Override
    public QueryUpdateService getUpdateService()
    {
        return new EventsTable.UpdateService(this);
    }

    protected class UpdateService extends SimpleQueryUpdateService
    {
        public UpdateService(SimpleUserSchema.SimpleTable ti)
        {
            super(ti, ti.getRealTable());
        }

        private final SNDService _sndService = SNDService.get();

        private void updateNarrativeCache(Container container, User user, List<Map<String, Object>> cacheData, Logger log)
        {
            if (cacheData.size() > 10000)
            {
                if (log != null)
                    log.info("Greater than 10,000 rows so not automatically populating narrative cache. Ensure to refresh manually.");
            }
            else if(cacheData.size() > 0)
            {
                if (log != null)
                    log.info("Repopulating affected rows in narrative cache.");
                _sndService.populateNarrativeCache(container, user, cacheData, log);
            }
        }

        private void deleteNarrativeCache(Container container, User user, List<Map<String, Object>> cacheData, Logger log)
        {
            if(cacheData.size() > 0)
            {
                if (log != null)
                    log.info("Deleting affected narrative cache rows.");
                _sndService.deleteNarrativeCacheRows(container, user, cacheData);
            }
        }

        private List<Map<String, Object>> handleNarrativeCache(DataIteratorBuilder rows, @Nullable Map<Enum,Object> configParameters, BatchValidationException errors)
        {
            List<Map<String, Object>> data;
            List<Map<String, Object>> cacheData = new ArrayList<>();
            DataIteratorContext dataIteratorContext = getDataIteratorContext(errors, InsertOption.MERGE, configParameters);

            try
            {
                data = _sndService.getMutableData(rows, dataIteratorContext);
            }
            catch (IOException e)
            {
                return cacheData;
            }

            Map<String, Object> cacheKey;
            for(Map<String, Object> map : data)
            {
                cacheKey = new HashMap<>();
                cacheKey.put("EventId", map.get("EventId"));
                cacheData.add(cacheKey);
            }

            return cacheData;
        }

        private Logger getLogger(Map<Enum, Object> configParameters)
        {
            Logger log = null;
            if (configParameters != null)
            {
                log = ((Logger) configParameters.get(QueryUpdateService.ConfigParameters.Logger));
            }

            return log;
        }

        @Override
        public int truncateRows(User user, Container container, @Nullable Map<Enum, Object> configParameters, @Nullable Map<String, Object> extraScriptContext)
                throws BatchValidationException, QueryUpdateServiceException, SQLException
        {
            _sndService.clearNarrativeCache(container, user);
            return super.truncateRows(user, container, configParameters, extraScriptContext);
        }

        @Override
        public int importRows(User user, Container container, DataIteratorBuilder rows, BatchValidationException errors,
                              @Nullable Map<Enum,Object> configParameters, Map<String, Object> extraScriptContext)
        {
            Logger log = getLogger(configParameters);

            if (log != null)
                log.info("Finding narrative cache rows.");

            List<Map<String, Object>> cacheData = handleNarrativeCache(rows, configParameters, errors);

            // Delete rows from narrative cache
            deleteNarrativeCache(container, user, cacheData, log);

            int result = super.importRows(user, container, rows, errors, configParameters, extraScriptContext);

            // update rows in narrative cache
            updateNarrativeCache(container, user, cacheData, log);
            return result;
        }

        @Override
        public int mergeRows(User user, Container container, DataIteratorBuilder rows, BatchValidationException errors,
                             @Nullable Map<Enum, Object> configParameters, Map<String, Object> extraScriptContext)
        {
            Logger log = getLogger(configParameters);

            if (log != null)
                log.info("Finding rows to cache.");

            List<Map<String, Object>> cacheData = handleNarrativeCache(rows, configParameters, errors);

            // Delete rows from narrative cache
            deleteNarrativeCache(container, user, cacheData, log);

            int result = super.mergeRows(user, container, rows, errors, configParameters, extraScriptContext);

            // update rows in narrative cache
            updateNarrativeCache(container, user, cacheData, log);
            return result;
        }

        @Override
        protected Map<String, Object> deleteRow(User user, Container container, Map<String, Object> oldRowMap) throws QueryUpdateServiceException, SQLException, InvalidKeyException
        {
            int eventId = (Integer) oldRowMap.get("EventId");
            String subjectId = (String) oldRowMap.get("SubjectId");
            Date eventDate = (Date) oldRowMap.get("Date");
            Integer qcState = (Integer) oldRowMap.get("QcState");

            BatchValidationException errors = new BatchValidationException();
            Event event = SNDManager.get().getEvent(container, user, eventId, null, null, true, errors);
            if (event == null || event.getEventId() == null)
            {
                throw new QueryUpdateServiceException("Event not found.");
            }

            if (!SNDSecurityManager.get().hasPermissionForTopLevelSuperPkgs(container, user, SNDManager.get().getTopLevelEventDataSuperPkgs(container, user, event), event, QCStateActionEnum.DELETE))
            {
                if (event.hasErrors())
                {
                    throw new QueryUpdateServiceException(event.getException());
                }
                else
                {
                    throw new QueryUpdateServiceException("You do not have permission to delete this event.");
                }
            }

            // This needs to be an atomic operation otherwise could get deadlock
            try (DbScope.Transaction tx = SNDSchema.getInstance().getSchema().getScope().ensureTransaction(SNDService.get().getWriteLock()))
            {
                SNDManager.get().deleteEventsCache(container, user, eventId);
                SNDManager.get().deleteEventDatas(container, user, eventId);
                SNDManager.get().deleteEventNotes(container, user, eventId);
                tx.commit();
            }
            catch (BatchValidationException e)
            {
                throw new QueryUpdateServiceException(e.getMessage());
            }

            NarrativeAuditProvider.addAuditEntry(container, user, eventId, subjectId, eventDate, null, qcState, "Delete event");

            List<Map<String, Object>> cacheData = new ArrayList<>();
            Map<String, Object> cacheKey = new HashMap<>();
            cacheKey.put("EventId", oldRowMap.get("EventId"));
            cacheData.add(cacheKey);

            // now delete package row
            Map<String, Object> result = super.deleteRow(user, container, oldRowMap);

            // delete row from narrative cache
            deleteNarrativeCache(container, user, cacheData, null);

            return result;
        }
    }
}
