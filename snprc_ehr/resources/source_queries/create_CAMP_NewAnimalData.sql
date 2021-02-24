/*******************************************************************
Creates TAC schema if needed, then table to hold new animal data
  entered in TAC


06.22.2020 srr

Changed the schema back to labkey_etl for simplicity.
  May revert back to TAC schema at a later date if there
  are more tables and better organization is needed.
  Left PK as PK_TAC_NEWANIMALDATA
07.06.2020 srr
*******************************************************************/


/*
-- Create TAC schema if not exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'TAC')
BEGIN
    -- The schema must be run in its own batch!
EXEC( 'CREATE SCHEMA TAC' );
END
*/

/*********  Create animal schema LabkeyETL if it doesn not exist ******/
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'TAC_src')
EXEC('CREATE SCHEMA [TAC_src] AUTHORIZATION [DBO]');


-- NOTE SQL Server 2016 and after
DROP TABLE IF EXISTS labkey_etl.NewAnimalData;
-- new schema
DROP TABLE IF EXISTS TAC_src.Pkgs;

CREATE TABLE TAC_src.NewAnimalData
(
    tid INT IDENTITY,
    Id VARCHAR(6) NOT NULL,
    BirthDate DATETIME NULL,
    Bd_Status INT NULL,
    AcquisitionType INT NULL,
    AcquisitionDate DATETIME NULL, -- Start date for Data Tables
    Gender CHAR(1) NULL,
    Sire VARCHAR(6) NULL,
    Dam VARCHAR(6) NULL,
    Species VARCHAR(3) NULL,
    ColonyText VARCHAR(30),
    PedigreeText VARCHAR(20) NULL,
    PedigreeInt INT NULL,
    AnimalAccount VARCHAR(15) NULL,
    OwnerInstitution INT NULL,
    ResponsibleInstitution INT NULL,
    Room VARCHAR(10) NULL, -- Bay
    Cage INT NULL,
    DietInt INT NULL,
    DietText VARCHAR(20) NULL,
    IACUC VARCHAR(7) NULL,
    ETLDownDate [DATETIME] DEFAULT GETDATE(),
    Created DATETIME NULL,
    CreatedBy Int NULL,
    CreatedByEmail    VARCHAR(128) NULL,
    CreatedUserName VARCHAR(128) NULL,
    Modified DATETIME NULL,
    ModifiedBy Int NULL,
    ModifiedByEmail varchar(128) NULL,
    Container UNIQUEIDENTIFIER NOT NULL,
    objectid UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT PK_TAC_NEWANIMALDATA
        PRIMARY KEY CLUSTERED (tid ASC)
)

go

/*****   Insert trigger that distributes the data to Animal tables   *****/

/***********************************************************************************
-- =============================================
--
-- Create date: 10/16/2020
-- Description:	Will disperse New Animal Data (NAD) to animal database tables.
--
-- 11.09.2020 srr
-- updated from TAC_NADinsert test code.
-- fixed colony,
-- =============================================

09 Nov 2020 12:37:05,411 ERROR: Cannot insert the value NULL into column 'user_name', table 'animal.dbo.master';
							column does not allow nulls. INSERT fails.
turned off trigger and exported
NAD broke between 7/9/20 and 8/25/20
srouse	srouse@vogon	2020-07-09 09:58:03.963
NULL	srouse@vogon	2020-08-25 16:29:32.860
***********************************************************************************/


CREATE TRIGGER [TAC_src].[ti_NewAnimalData] ON [TAC_src].[NewAnimalData] FOR INSERT AS
BEGIN
DECLARE
@numrows  int,
      -- not used @numnull  int,
      @errno    int,
      @errmsg   varchar(255)

select  @numrows = @@rowcount
            if @numrows = 0
      return
 /******************  Functional code START ********************************/

 -- set local vars
DECLARE @n	INT --nummber needed
-- vars for get next multilple ids
DECLARE @cntInt INT
DECLARE @cntChar VARCHAR(10)
DECLARE @insertDateTime DATETIME
SET @insertDateTime = GETDATE()

-- Format for TxBiomed Varchar 6 len animal IDs
DECLARE @TxIds TABLE(
	tid INT NOT NULL,
	ID_TAC VARCHAR(6) NOT NULL,
	id	VARCHAR(6) NULL,
	sire VARCHAR(6) NULL,
	dam	 VARCHAR(6) NULL,
	CreatedBy VARCHAR(128) NULL
	);

INSERT INTO @TxIds( tid, ID_TAC, id, sire, dam,CreatedBy)
SELECT tid,
       -- tjh id bufffer method
       RIGHT(SPACE(6) + id, 6),
       RIGHT(SPACE(6) + id, 6),
       RIGHT(SPACE(6) + sire, 6),
       RIGHT(SPACE(6) + dam, 6),
       CreatedUserName
FROM inserted i;

-- dam processing
-- insert shim for adding new data types
/*
SELECT t.id,
		t.CreatedBy
	FROM inserted i
		INNER JOIN @TxIds t
		ON i.tid = t.tid
*/

-- add master data
INSERT INTO dbo.master
( id ,
  birth_date ,
  bd_status ,
  sex ,
  species,
  sire_id,
  dam_id,
  user_name,
  entry_date_tm
)
SELECT t.id, i.BirthDate, i.Bd_Status, i.Gender, i.Species,
       t.sire, t.dam,t.CreatedBy, @insertDateTime
FROM inserted i
         INNER JOIN @TxIds t
ON i.tid = t.tid


INSERT INTO dbo.acq_disp
( id ,
  acq_date_tm ,
  acq_code,
  user_name,
  entry_date_tm
)
SELECT t.id, i.AcquisitionDate, i.AcquisitionType, t.CreatedBy, @insertDateTime
FROM inserted i
         INNER JOIN @TxIds t
ON i.tid = t.tid

INSERT INTO dbo.accounts
( id ,
  assign_date ,
  account ,
  user_name,
  entry_date_tm
)
SELECT t.id, i.AcquisitionDate, i.AnimalAccount, t.CreatedBy, @insertDateTime
FROM inserted i
         INNER JOIN @TxIds t
ON i.tid = t.tid
-- need to join on valid_diet
INSERT INTO dbo.diet
( id ,
  start_date ,
  diet,
  user_name,
  entry_date_tm
)
SELECT t.id, i.AcquisitionDate, vd.diet,
       t.CreatedBy, @insertDateTime
FROM inserted i
         INNER JOIN @TxIds t
ON i.tid = t.tid
    INNER JOIN dbo.valid_diet vd
    ON i.DietInt = vd.tid;

-- ownership
INSERT INTO  dbo.animal_ownership
(
    id,
    owner_institution_id,
    responsible_institution_id,
    institution_acquired_from_id,
    assign_date,
    end_date,
    user_name,
    entry_date_tm
)

SELECT t.id, i.OwnerInstitution, i.ResponsibleInstitution, NULL, i.AcquisitionDate, NULL, t.CreatedBy, @insertDateTime
FROM inserted i
         INNER JOIN @TxIds t
ON i.tid = t.tid;

INSERT INTO dbo.colony
( id ,
  start_date_tm,
  colony,
  user_name,
  entry_date_tm
)
SELECT t.id, i.AcquisitionDate, i.ColonyText,
       t.CreatedBy, @insertDateTime
FROM inserted i
         INNER JOIN @TxIds t
ON i.tid = t.tid
    INNER JOIN dbo.valid_colonies vc
    ON i.ColonyText = vc.colony

INSERT INTO dbo.pedigree
(
    id,
    pedigree,
    start_date,
    user_name,
    entry_date_tm
)
SELECT t.id, i.PedigreeText, i.AcquisitionDate,
       t.CreatedBy, @insertDateTime
FROM inserted i
         INNER JOIN @TxIds t
ON i.tid = t.tid
WHERE i.PedigreeText IS NOT NULL;

INSERT INTO dbo.arc_animal_assignments
( id ,
  start_date,
  arc_num_seq ,
  arc_num_genus ,
  status ,
  comments,
  user_name,
  entry_date_tm
)
SELECT t.id, i.AcquisitionDate, CAST(LEFT(i.IACUC,LEN(i.IACUC)-2) AS INT), RIGHT(i.IACUC,2),'A','TAC ETL',
       t.CreatedBy, @insertDateTime
FROM inserted i
         INNER JOIN @TxIds t
ON i.tid = t.tid;



-- move to SNPRC loc
INSERT INTO dbo.location
( id ,
  move_date_tm ,
  location,
  user_name,
  entry_date_tm
)
-- insert shim
SELECT t.id, i.AcquisitionDate, CAST(i.Room AS NUMERIC(7,2)),
       t.CreatedBy, @insertDateTime
FROM inserted i
         INNER JOIN @TxIds t
ON i.tid = t.tid;

-- add Primary ID to id_history
INSERT INTO dbo.id_history
( sfbr_id ,
  id_date ,
  id_value ,
  id_type ,
  institution_id ,
  comment,
  user_name,
  entry_date_tm
)
SELECT t.id, i.AcquisitionDate, t.id, 1, 1, 'ETL from TAC',
       t.CreatedBy, @insertDateTime
FROM inserted i
         INNER JOIN @TxIds t
ON i.tid = t.tid;
-- Add trimmed id as TxBiomed Tattoo
-- exclude hamsters
INSERT INTO dbo.id_history
( sfbr_id ,
  id_date ,
  id_value ,
  id_type ,
  institution_id ,
  comment,
  user_name,
  entry_date_tm
)
SELECT t.id, i.AcquisitionDate, t.id, 3, 1, 'ETL from TAC',
       t.CreatedBy, @insertDateTime
FROM inserted i
         INNER JOIN @TxIds t
ON i.tid = t.tid
WHERE i.Species NOT IN ('HAM')
    /******************  Functional code END ********************************/


    RETURN  -- all is well


/* Error handling */
    error:
    RAISERROR( '%d: %s', 16, 0, @errno, @errmsg);
ROLLBACK  TRANSACTION;
END
    GO

ALTER TABLE [TAC_src].[NewAnimalData] ENABLE TRIGGER [ti_NewAnimalData]
    GO

-- Table permits
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON TAC_src.NewAnimalData TO z_labkey;
GRANT VIEW DEFINITION ON TAC_src.NewAnimalData TO z_labkey;
GO