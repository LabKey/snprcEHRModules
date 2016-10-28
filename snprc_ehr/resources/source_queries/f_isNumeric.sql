/*
 * Copyright (c) 2015-2016 LabKey Corporation
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
