USE
[TAC_HL7_staging]
GO
/****** Object:  UserDefinedFunction [dbo].[f_format_hl7_date]    Script Date: 3/23/2022 11:14:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Terry Hawkins
-- Create date: 1/30/2014
-- Description:	Converts a date and time string into MSSQL datetime format
-- =============================================
CREATE FUNCTION [dbo].[f_format_hl7_date]
(
	-- Add the parameters for the function here
	@date_str VARCHAR(50)
)
RETURNS DATETIME

AS
BEGIN
	DECLARE
@ret_date DATETIME
	IF LEN(@date_str) = 8
BEGIN
		--20140117
		SET
@ret_date = CAST(SUBSTRING(@date_str, 1,4)+ '-' + SUBSTRING(@date_str, 5,2) + '-' + SUBSTRING(@date_str,7,2) AS DATETIME)
END
ELSE
BEGIN
		--201401171008
		SET
@ret_date = CAST(SUBSTRING(@date_str, 1,4)+ '-' + SUBSTRING(@date_str, 5,2) + '-' + SUBSTRING(@date_str,7,2) +
			' ' + SUBSTRING(@date_str, 9,2) + ':' + SUBSTRING(@date_str, 11,2) AS DATETIME)
END

RETURN @ret_date

END
