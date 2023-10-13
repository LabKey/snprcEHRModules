/****** Object:  View [dbo].[v_sndSuperPackageParents]    Script Date: 10/6/2023 10:17:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[v_sndSuperPackageParents]
AS
SELECT DISTINCT p.PKG_ID, sp.PARENT_PKG_ID, p.DESCRIPTION, sp.SUPER_PKG_ID, sp2.SUPER_PKG_ID AS PARENT_SUPER_PKG_ID
FROM dbo.SUPER_PKGS AS sp
         LEFT  JOIN dbo.PKGS AS p ON p.PKG_ID = sp.PKG_ID
         LEFT JOIN dbo.SUPER_PKGS AS sp2 ON sp2.PKG_ID = sp.PARENT_PKG_ID
    GO
