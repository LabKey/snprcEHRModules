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

CREATE INDEX IDX_SND_PKGS_LSID ON snd.Pkgs(Lsid);
CREATE INDEX IDX_SND_SUPERPKGS_LSID ON snd.SuperPkgs(Lsid);
CREATE INDEX IDX_SND_PKGCATEGORIES_LSID ON snd.PkgCategories(Lsid);
CREATE INDEX IDX_SND_PKGCATEGORYJUNCTION_LSID ON snd.PkgCategoryJunction(Lsid);
CREATE INDEX IDX_SND_PROJECTS_LSID ON snd.Projects(Lsid);
CREATE INDEX IDX_SND_PROJECTITEMS_LSID ON snd.ProjectItems(Lsid);
CREATE INDEX IDX_SND_EVENTS_LSID ON snd.Events(Lsid);
CREATE INDEX IDX_SND_CODEDEVENTS_LSID ON snd.CodedEvents(Lsid);
CREATE INDEX IDX_SND_EVENTNOTES_LSID ON snd.EventNotes(Lsid);

ALTER TABLE snd.Pkgs ADD Narrative NVARCHAR(MAX) NULL;
