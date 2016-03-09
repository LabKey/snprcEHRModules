CREATE TABLE snprc_ehr.validAccounts(
	account varchar(16) NOT NULL,
	accountStatus varchar(1) NOT NULL,
	date DATETIME NOT NULL,
	endDate DATETIME NULL,
	description VARCHAR(100) NULL,
	accountGroup VARCHAR(20) NOT NULL,
	userName VARCHAR(128) NOT NULL,
	entryDateTm DATETIME NOT NULL,
	Container	entityId NOT NULL,
	Created DATETIME,
  CreatedBy USERID,
  Modified DATETIME,
  ModifiedBy USERID,
	objectid NVARCHAR(4000)

 CONSTRAINT [PK_VALID_ACCOUNTS] PRIMARY KEY CLUSTERED (	account ASC )

);
GO