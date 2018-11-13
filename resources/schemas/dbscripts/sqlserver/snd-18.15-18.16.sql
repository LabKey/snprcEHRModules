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

ALTER TABLE snd.EventNotes
DROP CONSTRAINT PK_SND_EVENTNOTES;
DROP INDEX IDX_SND_EVENTNOTES_EVENTNOTEID ON snd.EventNotes;
GO

ALTER TABLE snd.EventNotes
DROP COLUMN EventNoteId;
GO

ALTER TABLE snd.EventNotes ADD EventNoteId INT IDENTITY(1, 1) NOT NULL;
GO

ALTER TABLE snd.EventNotes ADD CONSTRAINT PK_SND_EVENTNOTES PRIMARY KEY (EventNoteId);
CREATE INDEX IDX_SND_EVENTNOTES_EVENTNOTEID ON snd.EventNotes(EventNoteId);

EXEC core.fn_dropifexists 'EventData', 'snd', 'COLUMN', 'ObjectId';