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