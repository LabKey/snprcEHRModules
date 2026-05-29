/*
 * Copyright (c) 2023-2026 LabKey Corporation
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
package org.labkey.api.snd;

public class EventNote
{
    private Integer _eventId;
    private String _note;
    private Integer _eventNoteId;
    private String _container;

    public static final String EVENT_ID = "eventId";
    public static final String NOTE = "note";
    public static final String EVENT_NOTE_ID = "eventNoteId";
    public static final String CONTAINER = "Container";

    public EventNote(Integer eventId, String note, Integer eventNoteId) {
        _eventId = eventId;
        _note = note;
        _eventNoteId = eventNoteId;
    }

    public EventNote () {}

    public Integer getEventId()
    {
        return _eventId;
    }

    public void setEventId(Integer eventId)
    {
        _eventId = eventId;
    }

    public String getNote() { return _note; }

    public void setNote(String note) { _note = note; }

    public Integer getEventNoteId() { return _eventNoteId; }

    public void setEventNoteId(Integer eventNoteId) { _eventNoteId = eventNoteId; }

}
