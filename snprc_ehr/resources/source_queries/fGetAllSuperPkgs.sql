/****** Object:  UserDefinedFunction snd.fGetAllSuperPkgs    Script Date: 10/6/2023 10:36:51 AM ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
ALTER FUNCTION labkey_etl.fGetAllSuperPkgs
()
RETURNS @expandedSuperPackages TABLE
(
    TopLevelPkgId INTEGER NOT NULL,
    SuperPkgId INTEGER NOT NULL,
    ParentSuperPkgId INTEGER NULL,
    PkgId INTEGER NOT NULL,
    TreePath VARCHAR(MAX) NOT NULL,
    SuperPkgPath VARCHAR(MAX) NOT NULL,
    SortOrder INTEGER NULL,
    Required INTEGER NULL,
    DESCRIPTION VARCHAR(MAX) NOT NULL,
    Narrative VARCHAR(MAX) NOT NULL,
    Active INTEGER NOT NULL,
    Repeatable INTEGER NOT NULL,
    Level INTEGER NOT NULL,
    Created DATETIME NOT NULL,
    CreatedBy VARCHAR(MAX) NOT NULL,
    Modified DATETIME NOT NULL,
    ModifiedBy VARCHAR(MAX) NOT NULL
)
AS
BEGIN
    DECLARE @loopCursor CURSOR;
    DECLARE @topLevelPkgId INTEGER;

    SET @loopCursor = CURSOR LOCAL FOR
    SELECT  Pkg_Id AS topLevelPackageId
    FROM
        dbo.v_superPackageParents AS tl
    WHERE
        tl.PARENT_SUPER_PKG_ID IS NULL
    FOR READ ONLY;

    OPEN @loopCursor;
    FETCH @loopCursor
    INTO @topLevelPkgId;

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        INSERT INTO @expandedSuperPackages
        (
            TopLevelPkgId,
            SuperPkgId,
            ParentSuperPkgId,
            PkgId,
            TreePath,
            SuperPkgPath,
            SortOrder,
            Required,
            DESCRIPTION,
            Narrative,
            Active,
            Repeatable,
            Level,
            Created,
            CreatedBy,
            Modified,
            ModifiedBy
        )
        (SELECT TopLevelPkgId,
                SuperPkgId,
                ParentSuperPkgId,
                PkgId,
                SuperPkgPath,
                SuperPkgPath,
                SortOrder,
                Required,
                Description,
                Narrative,
                Active,
                Repeatable,
                Level,
                Created,
                dbo.f_map_username(CreatedBy)  AS CreatedBy,
                Modified,
                dbo.f_map_username(ModifiedBy) AS ModifiedBy
         FROM
                labkey_etl.fGetSuperPkg(@topLevelPkgId) );

        FETCH NEXT FROM @loopCursor
        INTO @topLevelPkgId;

    END;

    CLOSE @loopCursor;
    DEALLOCATE @loopCursor;

    RETURN;
END;