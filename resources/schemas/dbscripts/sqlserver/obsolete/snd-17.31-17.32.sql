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
EXEC core.fn_dropifexists 'ProjectItems', 'snd', 'CONSTRAINT', 'FK_SND_PROJECTITEMS_PARENTOBJECTID';
EXEC core.fn_dropifexists 'Events', 'snd', 'CONSTRAINT', 'FK_SND_EVENTS_PARENTOBJECTID';
GO

DELETE FROM snd.ProjectItems;
DELETE FROM snd.CodedEvents;
DELETE FROM snd.Events;
GO

ALTER TABLE snd.ProjectItems
ADD CONSTRAINT FK_SND_PROJECTITEMS_PARENTOBJECTID FOREIGN KEY (ParentObjectId) REFERENCES snd.Projects (ObjectId)

ALTER TABLE snd.Events
ADD CONSTRAINT FK_SND_EVENTS_PARENTOBJECTID FOREIGN KEY (ParentObjectId) REFERENCES snd.Projects (ObjectId)