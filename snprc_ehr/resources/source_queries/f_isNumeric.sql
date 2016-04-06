USE [animal]
GO
/****** Object:  UserDefinedFunction [dbo].[f_isNumeric]    Script Date: 2/29/2016 4:04:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================
-- Author:		Terry Hawkins
-- Create date: 2/28/14
-- Description:	Returns 1 if the value is numeric, 0 if value is not numeric
-- 6/19/2015	added additional criteria based on the current datasets. tjh
-- 2/29/2016  fixed file formatting.  Fixed bug in patindex call (removed). tjh
-- ==========================================================================
ALTER FUNCTION [dbo].[f_isNumeric]
(
	@value VARCHAR(MAX)
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @return INT


	IF (@value IS NULL) 
	BEGIN
		SET @return = 0
		GOTO finis
	END

	    
	select @value =  LTRIM(RTRIM(REPLACE(@value, ' ', '')))

	IF (ISNUMERIC(@value) = 1)
	BEGIN
		if ( LEN(@value) = 1 AND  CHARINDEX ('+', @value, 1) > 0) 
		OR ( LEN(@value) = 1 AND CHARINDEX('-', @value, 1) > 0)
		OR (CHARINDEX(',', @value, 1) > 0)
		OR (CHARINDEX('-' , @value, 2) > 1) 
		 
		BEGIN 
			SET @return = 0
			GOTO finis
		END 

		SET @return = 1	
		GOTO finis
				
	END 
	
	SET @return = 0

finis:
	RETURN @return

END
