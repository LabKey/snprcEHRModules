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

-- Create schema, tables, indexes, and constraints used for SND module here
-- All SQL VIEW definitions should be created in snd-create.sql and dropped in snd-drop.sql

EXEC core.fn_dropifexists 'CodedEvents','codedprocs','TABLE';
GO

EXEC core.fn_dropifexists 'EventNotes','codedprocs','TABLE';
GO

EXEC core.fn_dropifexists 'EventsCache','codedprocs','TABLE';
GO

EXEC core.fn_dropifexists 'PkgCategoryJunction','codedprocs','TABLE';
GO

EXEC core.fn_dropifexists 'ProjectItems','codedprocs','TABLE';
GO

EXEC core.fn_dropifexists 'SuperPkgs','codedprocs','TABLE';
GO

EXEC core.fn_dropifexists 'PkgCategories','codedprocs','TABLE';
GO

EXEC core.fn_dropifexists 'Pkgs','codedprocs','TABLE';
GO

EXEC core.fn_dropifexists 'Events','codedprocs','TABLE';
GO

EXEC core.fn_dropifexists 'Projects','codedprocs','TABLE';
GO

EXEC core.fn_dropifexists NULL,'codedprocs','SCHEMA';
GO

CREATE SCHEMA snd;
GO

/*==============================================================*/
/* Table: Pkgs                                                  */
/*==============================================================*/
CREATE TABLE snd.Pkgs (
   PkgId                INTEGER              NOT NULL,
   Description          NVARCHAR(4000)       NOT NULL,
   Active               BIT,
   Repeatable           BIT,
   QcState              INTEGER,
   ObjectId             UNIQUEIDENTIFIER     NOT NULL DEFAULT newid(),
   Container			      ENTITYID			       NOT NULL,
   CreatedBy			      USERID,
   Created				      DATETIME,
   ModifiedBy			      USERID,
   Modified				      DATETIME,
   Lsid                 LSIDType,

   CONSTRAINT PK_SND_PKGS PRIMARY KEY (PkgId),
   CONSTRAINT FK_SND_PKGS_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId),
   CONSTRAINT FK_SND_PKGS_QCSTATE FOREIGN Key (QcState) REFERENCES core.QCState (RowId)

)
GO

CREATE INDEX IDX_SND_PKGS_CONTAINER ON snd.Pkgs(Container);
CREATE INDEX IDX_SND_PKGS_QCSTATE ON snd.Pkgs(QcState);
GO

/*==============================================================*/
/* Table: SuperPkgs                                             */
/*==============================================================*/
CREATE TABLE snd.SuperPkgs (
   SuperPkgId           INTEGER              NOT NULL,
   ParentSuperPkgId     INTEGER,
   PkgId                INTEGER              NOT NULL,
   SuperPkgPath         VARCHAR(900)         NOT NULL,
   Container			      ENTITYID			       NOT NULL,
   CreatedBy			      USERID,
   Created				      DATETIME,
   ModifiedBy			      USERID,
   Modified				      DATETIME,
   Lsid                 LSIDType,

   CONSTRAINT PK_SND_SUPERPKGS PRIMARY KEY (SuperPkgId),
   CONSTRAINT FK_SND_SUPERPKGS_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId),
   CONSTRAINT FK_SND_SUPERPKGS_PKGID FOREIGN KEY (PkgId) REFERENCES snd.Pkgs (PkgId)

)
GO

CREATE INDEX IDX_SND_SUPERPKGS_CONTAINER ON snd.SuperPkgs(Container);
CREATE INDEX IDX_SND_SUPERPKGS_PKGID ON snd.SuperPkgs(PkgId);
GO

/*==============================================================*/
/* Table: PkgCategories                                         */
/*==============================================================*/
CREATE TABLE snd.PkgCategories (
   CategoryId           INTEGER              NOT NULL,
   Description          NVARCHAR(4000)       NOT NULL,
   Comment              NVARCHAR(4000),
   Active               BIT                  NOT NULL,
   SortOrder            INTEGER,
   Container			      ENTITYID			       NOT NULL,
   CreatedBy			      USERID,
   Created				      DATETIME,
   ModifiedBy			      USERID,
   Modified				      DATETIME,
   Lsid                 LSIDType,

   CONSTRAINT PK_SND_PKGCATEGORIES PRIMARY KEY (CategoryId),
   CONSTRAINT FK_SND_PKGCATEGORIES_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)

)
GO

CREATE INDEX IDX_SND_PKGCATEGORIES_CONTAINER ON snd.PkgCategories(Container);
GO

/*==============================================================*/
/* Table: PkgCategoryJunction                                   */
/*==============================================================*/
CREATE TABLE snd.PkgCategoryJunction (
   PkgId                INTEGER              NOT NULL,
   CategoryId           INTEGER              NOT NULL,
   Container			      ENTITYID			       NOT NULL,
   CreatedBy			      USERID,
   Created				      DATETIME,
   ModifiedBy			      USERID,
   Modified				      DATETIME,
   Lsid                 LSIDType,

   CONSTRAINT PK_SND_PKGCATEGORYJUNCTION PRIMARY KEY (PkgId, CategoryId),
   CONSTRAINT FK_SND_PKGCATEGORYJUNCTION_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId),
   CONSTRAINT FK_SND_PKGCATEGORYJUNCTION_PKGID FOREIGN KEY (PkgId) REFERENCES snd.Pkgs (PkgId),
   CONSTRAINT FK_SND_PKGCATEGORYJUNCTION_CATEGORYID FOREIGN KEY (CategoryId) REFERENCES snd.PkgCategories (CategoryId)

)
GO

CREATE INDEX IDX_SND_PKGCATEGORYJUNCTION_CONTAINER ON snd.PkgCategoryJunction(Container);
CREATE INDEX IDX_SND_PKGCATEGORYJUNCTION_PKGID ON snd.PkgCategoryJunction(PkgId);
CREATE INDEX IDX_SND_PKGCATEGORYJUNCTION_CATEGORYID ON snd.PkgCategoryJunction(CategoryId);
GO

/*==============================================================*/
/* Table: Projects                                              */
/*==============================================================*/
CREATE TABLE snd.Projects (
   ProjectId            INTEGER              NOT NULL,
   RevisionNum          INTEGER              NOT NULL,
   ReferenceId          INTEGER              NOT NULL,
   StartDate            date                 NOT NULL,
   EndDate              date,
   Description          NVARCHAR(4000)       NOT NULL,
   ObjectId             UNIQUEIDENTIFIER     NOT NULL DEFAULT newid(),
   Container			      ENTITYID			       NOT NULL,
   CreatedBy			      USERID,
   Created				      DATETIME,
   ModifiedBy			      USERID,
   Modified				      DATETIME,
   Lsid                 LSIDType,

   CONSTRAINT PK_SND_PROJECTS PRIMARY KEY (ProjectId, RevisionNum),
   CONSTRAINT FK_SND_PROJECTS_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)

)
GO

CREATE INDEX IDX_SND_PROJECTS_CONTAINER ON snd.Projects(Container);
CREATE UNIQUE INDEX IDX_SND_PROJECTS_OBJECTID ON snd.Projects(ObjectId);
GO

/*==============================================================*/
/* Table: ProjectItems                                          */
/*==============================================================*/
CREATE TABLE snd.ProjectItems (
   ProjectItemId        INTEGER              IDENTITY,
   ParentObjectId       UNIQUEIDENTIFIER,
   SuperPkgId           INTEGER              NOT NULL,
   Active               BIT                  NOT NULL DEFAULT 1,
   Container			      ENTITYID			       NOT NULL,
   CreatedBy			      USERID,
   Created				      DATETIME,
   ModifiedBy			      USERID,
   Modified				      DATETIME,
   Lsid                 LSIDType,

   CONSTRAINT PK_SND_PROJECTITEMS PRIMARY KEY (ProjectItemId),
   CONSTRAINT FK_SND_PROJECTITEMS_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId),
   CONSTRAINT FK_SND_PROJECTITEMS_SUPERPKGID FOREIGN KEY (SuperPkgId) REFERENCES snd.SuperPkgs (SuperPkgId),
   CONSTRAINT FK_SND_PROJECTITEMS_PARENTOBJECTID FOREIGN KEY (ParentObjectId) REFERENCES snd.Projects (ObjectId)

)
GO

CREATE INDEX IDX_SND_PROJECTITEMS_CONTAINER ON snd.ProjectItems(Container);
CREATE INDEX IDX_SND_PROJECTITEMS_SUPERPKGID ON snd.ProjectItems(SuperPkgId);
CREATE INDEX IDX_SND_PROJECTITEMS_PARENTOBJECTID ON snd.ProjectItems(ParentObjectId);
GO

/*==============================================================*/
/* Table: Events                                                */
/*==============================================================*/
CREATE TABLE snd.Events (
   EventId              INTEGER              NOT NULL,
   Id                   NVARCHAR(32)         NOT NULL,
   ParentObjectId       UNIQUEIDENTIFIER,
   Date                 DATETIME             NOT NULL,
   QcState              int,
   ObjectId             UNIQUEIDENTIFIER     NOT NULL DEFAULT newid(),
   Container			      ENTITYID			       NOT NULL,
   CreatedBy			      USERID,
   Created				      DATETIME,
   ModifiedBy			      USERID,
   Modified				      DATETIME,
   Lsid                 LSIDType,

   CONSTRAINT PK_SND_EVENTS PRIMARY KEY (EventId),
   CONSTRAINT FK_SND_EVENTS_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId),
   CONSTRAINT FK_SND_EVENTS_QCSTATE FOREIGN Key (QcState) REFERENCES core.QCState (RowId),
   CONSTRAINT FK_SND_EVENTS_PARENTOBJECTID FOREIGN KEY (ParentObjectId) REFERENCES snd.Projects (ObjectId)

)
GO

CREATE INDEX IDX_SND_EVENTS_CONTAINER ON snd.Events(Container);
CREATE INDEX IDX_SND_EVENTS_QCSTATE ON snd.Events(QcState);
CREATE INDEX IDX_SND_EVENTS_PARENTOBJECTID ON snd.Events(ParentObjectId);
GO

/*==============================================================*/
/* Table: CodedEvents                                           */
/*==============================================================*/
CREATE TABLE snd.CodedEvents (
   CodedEventId         INTEGER              IDENTITY,
   EventId              INTEGER              NOT NULL,
   SuperPkgId           INTEGER              NOT NULL,
   ObjectId             UNIQUEIDENTIFIER     NULL DEFAULT newid(),
   Container			      ENTITYID			       NOT NULL,
   CreatedBy			      USERID,
   Created				      DATETIME,
   ModifiedBy			      USERID,
   Modified				      DATETIME,
   Lsid                 LSIDType,

   CONSTRAINT PK_SND_CODEDEVENTS PRIMARY KEY (CodedEventId),
   CONSTRAINT FK_SND_CODEDEVENTS_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId),
   CONSTRAINT FK_SND_CODEDEVENTS_EVENTID FOREIGN KEY (EventId) REFERENCES snd.Events (EventId),
   CONSTRAINT FK_SND_CODEDEVENTS_SUPERPKGID FOREIGN KEY (SuperPkgId) REFERENCES snd.SuperPkgs(SuperPkgId)

)
GO

CREATE INDEX IDX_SND_CODEDEVENTS_CONTAINER ON snd.CodedEvents(Container);
CREATE INDEX IDX_SND_CODEDEVENTS_EVENTID ON snd.CodedEvents(EventId);
CREATE INDEX IDX_SND_CODEDEVENTS_SUPERPKGID ON snd.CodedEvents(SuperPkgId);
GO

/*==============================================================*/
/* Table: EventNotes                                            */
/*==============================================================*/
CREATE TABLE snd.EventNotes (
   EventNoteId          INTEGER              IDENTITY,
   EventId              INTEGER,
   Note                 NVARCHAR(MAX)        NOT NULL,
   Container			      ENTITYID			       NOT NULL,
   CreatedBy			      USERID,
   Created				      DATETIME,
   ModifiedBy			      USERID,
   Modified				      DATETIME,
   Lsid                 LSIDType,

   CONSTRAINT PK_SND_EVENTNOTES PRIMARY KEY (EventNoteId),
   CONSTRAINT FK_SND_EVENTNOTES_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId),
   CONSTRAINT FK_SND_EVENTNOTES_EVENTNOTEID FOREIGN KEY (EventNoteId) REFERENCES snd.Events (EventId)

)
GO

CREATE INDEX IDX_SND_EVENTNOTES_CONTAINER ON snd.EventNotes(Container);
CREATE INDEX IDX_SND_EVENTNOTES_EVENTNOTEID ON snd.EventNotes(EventNoteId);
GO



