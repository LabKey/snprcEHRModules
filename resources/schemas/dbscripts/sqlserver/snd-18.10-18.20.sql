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
/* snd-18.10-18.11.sql */

sp_rename 'snd.Events.ParticipantId', 'SubjectId', 'COLUMN';

/* snd-18.11-18.12.sql */

/*==============================================================*/
/* Table: EventsCache                                           */
/*==============================================================*/
CREATE TABLE snd.EventsCache (
  EventId              INTEGER              NOT NULL,
  HtmlNarrative        NVARCHAR(MAX),

  CONSTRAINT PK_SND_EVENTS_CACHE PRIMARY KEY (EventId)
)
  GO

/* snd-18.12-18.13.sql */

ALTER TABLE snd.EventsCache
  ADD CONSTRAINT FK_EventsCache_EventId FOREIGN KEY (EventId) REFERENCES snd.Events (EventId);
GO

/* snd-18.13-18.14.sql */

ALTER TABLE snd.EventData ADD ObjectId UNIQUEIDENTIFIER NOT NULL DEFAULT newid();
GO

/* snd-18.14-18.15.sql */

ALTER TABLE snd.EventsCache ADD Container entityid;
ALTER TABLE snd.EventsCache ADD CONSTRAINT FK_SND_EVENTSCACHE_CONTAINER FOREIGN KEY (Container) REFERENCES core.Containers (EntityId);
CREATE INDEX IDX_SND_EVENTSCACHE_CONTAINER ON snd.EventsCache(Container);
GO

/* snd-18.15-18.16.sql */

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

/* snd-18.16-18.17.sql */

ALTER TABLE snd.SuperPkgs
ADD Required BIT NOT NULL DEFAULT 0;
EXEC core.fn_dropifexists 'fGetSuperPkg', 'snd', 'FUNCTION', INT;
GO

CREATE FUNCTION snd.fGetSuperPkg ( @TopLevelPkgId INT )
RETURNS TABLE
AS

-- ==========================================================================================
-- Author:          Terry Hawkins
-- Creation date: 9/22/2017
-- Description:  Table valued function to return hierarchical view of a superPkg
-- ==========================================================================================
-- Revising 4/3/2018 to add Required column
RETURN
    (
   WITH    CTE1 ( TopLevelPkgId, SuperPkgId, ParentSuperPkgId, PkgId, TreePath, SuperPkgPath, SortOrder, Required, DESCRIPTION, Narrative, Active, Repeatable, Level )
              AS (

   -- anchor member definition
                   SELECT   @TopLevelPkgId AS TopLevelPkgId ,
                            sp.SuperPkgId AS SuperPkgId ,
                            sp.ParentSuperPkgId AS ParentSuperPkgId ,
                            sp.PkgId AS PkgId ,
                            RIGHT(SPACE(3)
                                  + CONVERT(VARCHAR(MAX), ROW_NUMBER() OVER ( ORDER BY sp.SortOrder )),
                                  3) AS TreePath ,
                            sp.SuperPkgPath AS SuperPkgPath ,
                            sp.SortOrder AS SortOrder ,
                            sp.Required AS Required ,
                            p.Description AS Description ,
                            p.Narrative AS Narrative ,
                            p.Active AS Active ,
                            p.Repeatable AS Repeatable ,
                            1 AS Level
                   FROM     snd.SuperPkgs sp
                            INNER JOIN snd.Pkgs p ON sp.PkgId = p.PkgId
                   WHERE    sp.PkgId = @TopLevelPkgId
                            AND sp.ParentSuperPkgId IS NULL
                   UNION ALL
                   SELECT   @TopLevelPkgId AS TopLevelPkgId ,
                            sp.SuperPkgId AS SuperPkgId ,
                            c.SuperPkgId AS ParentSuperPkgId ,
                            sp.PkgId AS PkgId ,
                            c.TreePath + '/' + RIGHT(SPACE(3)
                                                     + CONVERT(VARCHAR(MAX), RIGHT(ROW_NUMBER() OVER ( ORDER BY sp.SortOrder ),
                                                              10)), 3) AS TreePath ,
                            sp.SuperPkgPath AS SuperPkgPath ,
                            sp.SortOrder AS SortOrder ,
                            sp.Required AS Required ,
                            p.Description AS Description ,
                            p.Narrative AS Narrative ,
                            p.Active AS Active ,
                            p.Repeatable AS Repeatable ,
                            c.Level + 1 AS Level
                   FROM     snd.SuperPkgs AS sp
                            INNER JOIN CTE1 AS c ON
                        -- add subpackages
                        sp.ParentSuperPkgId = c.SuperPkgId
                        -- add children of subpackages
                                OR sp.ParentSuperPkgId IN (SELECT  sp2.SuperPkgId FROM snd.SuperPkgs AS sp2 WHERE c.PkgId = sp2.PkgId AND sp2.ParentSuperPkgId IS NULL )

                            INNER JOIN snd.Pkgs AS p ON sp.PkgId = p.PkgId
                 )
    SELECT  @TopLevelPkgId AS TopLevelPkgId ,
            c.SuperPkgId AS SuperPkgId ,
            c.ParentSuperPkgId AS ParentSuperPkgId ,
            c.PkgId AS PkgId ,
            c.TreePath AS TreePath ,
            c.SuperPkgPath AS SuperPkgPath ,
            c.SortOrder AS SortOrder ,
            c.Required AS Required ,
            c.DESCRIPTION AS Description ,
            c.Narrative AS Narrative ,
            c.Active AS Active ,
            c.Repeatable AS Repeatable ,
            c.Level AS Level
    FROM    CTE1 c

);
GO

/* snd-18.17-18.18.sql */

CREATE INDEX IDX_SND_EVENTDATA_SUPERPKGID ON snd.EventData(SuperPkgId);
CREATE INDEX IDX_SND_EVENTDATA_EVENTID ON snd.EventData(EventId);