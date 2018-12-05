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
