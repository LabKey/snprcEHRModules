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
/* snd-17.30-17.31.sql */

EXEC core.fn_dropifexists 'Projects', 'snd', 'CONSTRAINT', 'IDX_SND_PROJECTS_CONTAINER';
EXEC core.fn_dropifexists 'Projects', 'snd', 'CONSTRAINT', 'IDX_SND_PROJECTS_OBJECTID';
EXEC core.fn_dropifexists 'ProjectItems', 'snd', 'CONSTRAINT', 'FK_SND_PROJECTITEMS_PARENTOBJECTID';
EXEC core.fn_dropifexists 'Events', 'snd', 'CONSTRAINT', 'FK_SND_EVENTS_PARENTOBJECTID';
GO

EXEC core.fn_dropifexists 'Projects', 'snd', 'TABLE', NULL
GO

CREATE TABLE snd.Projects (
   ProjectId            INTEGER              NOT NULL,
   RevisionNum          INTEGER              NOT NULL,
   ReferenceId          INTEGER              NOT NULL,
   StartDate            date                 NOT NULL,
   EndDate              date,
   Description          NVARCHAR(4000)       NOT NULL,
   Active				        BIT					         NOT NULL,
   ObjectId             UNIQUEIDENTIFIER     NOT NULL DEFAULT newid(),
   Container			      ENTITYID			       NOT NULL,
   CreatedBy			      USERID,
   Created				      DATETIME,
   ModifiedBy			      USERID,
   Modified				      DATETIME,
   Lsid                 LSIDType,

   CONSTRAINT PK_SND_PROJECTS PRIMARY KEY NONCLUSTERED (ObjectId),
   CONSTRAINT FK_SND_PROJECTS_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)

)
GO

CREATE INDEX IDX_SND_PROJECTS_CONTAINER ON snd.Projects(Container);
CREATE UNIQUE CLUSTERED INDEX IDX_SND_PROJECTS_PROJECTID_REVNUM ON snd.Projects(ProjectId, RevisionNum);
GO

/* snd-17.31-17.32.sql */

EXEC core.fn_dropifexists 'ProjectItems', 'snd', 'CONSTRAINT', 'FK_SND_PROJECTITEMS_PARENTOBJECTID';
EXEC core.fn_dropifexists 'Events', 'snd', 'CONSTRAINT', 'FK_SND_EVENTS_PARENTOBJECTID';
GO

DELETE FROM snd.ProjectItems;
DELETE FROM snd.CodedEvents;
DELETE FROM snd.Events;
GO

ALTER TABLE snd.ProjectItems
ADD CONSTRAINT FK_SND_PROJECTITEMS_PARENTOBJECTID FOREIGN KEY (ParentObjectId) REFERENCES snd.Projects (ObjectId);

ALTER TABLE snd.Events
ADD CONSTRAINT FK_SND_EVENTS_PARENTOBJECTID FOREIGN KEY (ParentObjectId) REFERENCES snd.Projects (ObjectId);
GO

/* snd-17.32-17.33.sql */

EXEC core.fn_dropifexists 'fGetProjectItems','snd', 'FUNCTION';
GO

CREATE FUNCTION [snd].[fGetProjectItems]
    (
      @projectId INT ,
      @revisionNum INT
    )
RETURNS TABLE
AS

-- ==========================================================================================
-- Author:			Terry Hawkins
-- Creation date:	12/14/2017
-- Description:		Returns the list of ProjectItems for a Project/Revision along with
--                  sub packages for each ProjectItem
-- ==========================================================================================
RETURN
    (
WITH    CTE1 ( ProjectId, RevisionNum, ProjectItemId, ParentObjectId, ParentSuperPkgId, SuperPkgId, PkgId, Active, TreePath, Level, Description )
          AS ( SELECT   @projectId AS ProjectId ,
                        @revisionNum AS RevisionNum ,
                        pi.ProjectItemId ,
                        pi.ParentObjectId AS ParentObjectId ,
                        sp.ParentSuperPkgId AS ParentSuperPkgId ,
                        sp.SuperPkgId AS SuperPkgId ,
                        sp.PkgId AS PkgId ,
                        p.Active ,
                        RIGHT(SPACE(3)
                              + CONVERT(VARCHAR(MAX), ROW_NUMBER() OVER ( ORDER BY pi.ProjectItemId, sp.SuperPkgId )),
                              3) AS TreePath ,
                        1 AS Level ,
                        pkg.Description
               FROM     snd.ProjectItems AS pi
                        INNER JOIN snd.Projects AS p ON pi.ParentObjectId = p.ObjectId
                        INNER JOIN snd.SuperPkgs AS sp ON pi.SuperPkgId = sp.SuperPkgId
                        INNER JOIN snd.Pkgs pkg ON sp.PkgId = pkg.PkgId
               WHERE    p.ProjectId = @projectId
                        AND p.RevisionNum = @revisionNum
               UNION ALL
               SELECT   c.ProjectId AS ProjectId ,
                        c.RevisionNum AS RevisionNum ,
                        c.ProjectItemId ,
                        c.ParentObjectId AS ParentObjectId ,
                        sp.ParentSuperPkgId AS ParentSuperPkgId ,
                        sp.SuperPkgId AS SuperPkgId ,
                        sp.PkgId AS PkgId ,
                        c.Active ,
                        c.TreePath + '/' + RIGHT(SPACE(3)
                                                 + CONVERT(VARCHAR(MAX), RIGHT(ROW_NUMBER() OVER ( ORDER BY sp.SortOrder ),
                                                              10)), 3) AS TreePath ,
                        c.Level + 1 AS Level ,
                        pkg.Description
               FROM     snd.SuperPkgs AS sp
                        INNER JOIN snd.Pkgs AS pkg ON sp.PkgId = pkg.PkgId
                        INNER JOIN CTE1 AS c ON sp.ParentSuperPkgId = c.SuperPkgId
												-- get the sub-pkg hierarchy from the top-level super pkg definition
                                                OR sp.ParentSuperPkgId IN (
                                                SELECT  sp2.SuperPkgId
                                                FROM    snd.SuperPkgs AS sp2
                                                WHERE   c.PkgId = sp2.PkgId
                                                        AND sp2.ParentSuperPkgId IS NULL) 
             )
    SELECT  @projectId AS ProjectId ,
            @revisionNum AS RevisionNum ,
            c.ProjectItemId ,
            c.SuperPkgId AS SuperPkgId ,
            c.PkgId AS PkgId ,
            c.TreePath AS TreePath ,
            c.Level AS Level ,
            c.Active AS Active ,
            c.Description
    FROM    CTE1 c

);
GO

/* snd-17.33-17.34.sql */

EXEC core.fn_dropifexists 'fGetProjectItems','snd', 'FUNCTION';
GO

CREATE FUNCTION [snd].[fGetProjectItems]
    (
      @projectId INT ,
      @revisionNum INT
    )
RETURNS TABLE
AS

-- ==========================================================================================
-- Author:			Terry Hawkins
-- Creation date:	12/14/2017
-- Description:		Returns the list of ProjectItems for a Project/Revision along with
--                  sub packages for each ProjectItem
-- ==========================================================================================
RETURN
    (
WITH    CTE1 ( ProjectId, RevisionNum, ProjectItemId, ParentObjectId, ParentSuperPkgId, SuperPkgId, PkgId, ProjectActive, Active, TreePath, Level, Description )
          AS ( SELECT   @projectId AS ProjectId ,
                        @revisionNum AS RevisionNum ,
                        pi.ProjectItemId ,
                        pi.ParentObjectId AS ParentObjectId ,
                        sp.ParentSuperPkgId AS ParentSuperPkgId ,
                        sp.SuperPkgId AS SuperPkgId ,
                        sp.PkgId AS PkgId ,
                        p.Active as ProjectActive,
                        pi.Active,
                        RIGHT(SPACE(3)
                              + CONVERT(VARCHAR(MAX), ROW_NUMBER() OVER ( ORDER BY pi.ProjectItemId, sp.SuperPkgId )),
                              3) AS TreePath ,
                        1 AS Level ,
                        pkg.Description
               FROM     snd.ProjectItems AS pi
                        INNER JOIN snd.Projects AS p ON pi.ParentObjectId = p.ObjectId
                        INNER JOIN snd.SuperPkgs AS sp ON pi.SuperPkgId = sp.SuperPkgId
                        INNER JOIN snd.Pkgs pkg ON sp.PkgId = pkg.PkgId
               WHERE    p.ProjectId = @projectId
                        AND p.RevisionNum = @revisionNum
               UNION ALL
               SELECT   c.ProjectId AS ProjectId ,
                        c.RevisionNum AS RevisionNum ,
                        c.ProjectItemId ,
                        c.ParentObjectId AS ParentObjectId ,
                        sp.ParentSuperPkgId AS ParentSuperPkgId ,
                        sp.SuperPkgId AS SuperPkgId ,
                        sp.PkgId AS PkgId ,
                        c.ProjectActive ,
                        c.Active ,
                        c.TreePath + '/' + RIGHT(SPACE(3)
                                                 + CONVERT(VARCHAR(MAX), RIGHT(ROW_NUMBER() OVER ( ORDER BY sp.SortOrder ),
                                                              10)), 3) AS TreePath ,
                        c.Level + 1 AS Level ,
                        pkg.Description
               FROM     snd.SuperPkgs AS sp
                        INNER JOIN snd.Pkgs AS pkg ON sp.PkgId = pkg.PkgId
                        INNER JOIN CTE1 AS c ON sp.ParentSuperPkgId = c.SuperPkgId
												-- get the sub-pkg hierarchy from the top-level super pkg definition
                                                OR sp.ParentSuperPkgId IN (
                                                SELECT  sp2.SuperPkgId
                                                FROM    snd.SuperPkgs AS sp2
                                                WHERE   c.PkgId = sp2.PkgId
                                                        AND sp2.ParentSuperPkgId IS NULL)
             )
    SELECT  @projectId AS ProjectId ,
            @revisionNum AS RevisionNum ,
            c.ProjectItemId ,
            c.SuperPkgId AS SuperPkgId ,
            c.PkgId AS PkgId ,
            c.TreePath AS TreePath ,
            c.Level AS Level ,
            c.ProjectActive ,
            c.Active ,
            c.Description
    FROM    CTE1 c

);
GO

/* snd-17.34-17.35.sql */

/* Recreate EventData table */
EXEC core.fn_dropifexists 'CodedEvents','snd','TABLE';
GO

/*==============================================================*/
/* Table: EventData                                             */
/*==============================================================*/
CREATE TABLE snd.EventData (
   EventDataId				  INTEGER         NOT NULL,
   EventId					    INTEGER         NOT NULL,
   SuperPkgId				    INTEGER         NOT NULL,
   ObjectURI				    LsidType		    NOT NULL,
   Container			      ENTITYID		    NOT NULL,
   CreatedBy			      USERID,
   Created				      DATETIME,
   ModifiedBy			      USERID,
   Modified				      DATETIME,
   Lsid						      LSIDType,

   CONSTRAINT PK_SND_EVENTDATA PRIMARY KEY (EventDataId),
   CONSTRAINT FK_SND_EVENTDATA_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId),
   CONSTRAINT FK_SND_EVENTDATA_EVENTID FOREIGN KEY (EventId) REFERENCES snd.Events (EventId),
   CONSTRAINT FK_SND_EVENTDATA_SUPERPKGID FOREIGN KEY (SuperPkgId) REFERENCES snd.SuperPkgs(SuperPkgId)
)
GO

/* Recreate EventNoteId not as identity column for etls */
ALTER TABLE snd.EventNotes DROP PK_SND_EVENTNOTES;
ALTER TABLE snd.EventNotes DROP CONSTRAINT FK_SND_EVENTNOTES_EVENTNOTEID;
DROP INDEX IDX_SND_EVENTNOTES_EVENTNOTEID ON snd.EventNotes;
GO

ALTER TABLE snd.EventNotes DROP COLUMN EventNoteId;
GO

ALTER TABLE snd.EventNotes ADD EventNoteId INTEGER NOT NULL;
GO

ALTER TABLE snd.EventNotes ADD CONSTRAINT PK_SND_EVENTNOTES PRIMARY KEY (EventNoteId);
ALTER TABLE snd.EventNotes ADD CONSTRAINT FK_SND_EVENTNOTES_EVENTNOTEID FOREIGN KEY (EventNoteId) REFERENCES snd.Events (EventId)
CREATE INDEX IDX_SND_EVENTNOTES_EVENTNOTEID ON snd.EventNotes(EventNoteId);
GO

/* snd-17.35-17.36.sql */

EXEC sp_rename 'snd.Events.Id', 'ParticipantId', 'COLUMN';

EXEC core.fn_dropifexists 'EventNotes', 'snd', 'CONSTRAINT', 'FK_SND_EVENTNOTES_EVENTNOTEID';
GO

ALTER TABLE snd.EventNotes ADD CONSTRAINT FK_SND_EVENTNOTES_EVENTID FOREIGN KEY (EventId) REFERENCES snd.Events (EventId)
GO

/* snd-17.36-17.37.sql */

ALTER TABLE snd.Lookups ADD   [ObjectId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID();
CREATE UNIQUE INDEX idx_snd_lookups_objectid ON snd.lookups (ObjectId);

ALTER TABLE snd.LookupSets ADD [ObjectId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID();
CREATE UNIQUE INDEX idx_snd_lookupSets_objectid ON snd.lookupSets (ObjectId);
GO

/* snd-17.37-17.38.sql */

ALTER TABLE snd.EventData ADD ParentEventDataId INT;
ALTER TABLE snd.EventData DROP COLUMN Modified;
ALTER TABLE snd.EventData DROP COLUMN ModifiedBy;
ALTER TABLE snd.EventData DROP COLUMN Created;
ALTER TABLE snd.EventData DROP COLUMN CreatedBy;