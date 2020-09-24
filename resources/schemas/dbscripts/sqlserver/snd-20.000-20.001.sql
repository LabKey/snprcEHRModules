/*
    Changes to improve snd.Events CRUD performance and add default QcState
*/

-- delete the trigger if it exists
IF (OBJECT_ID(N'snd.ti_after_Events') IS NOT NULL)
   BEGIN
       DROP TRIGGER snd.ti_after_Events;
   END;
GO
-- if QcState is null, set it to 'Completed'
CREATE TRIGGER snd.ti_after_Events ON snd.Events FOR INSERT AS
BEGIN
    SET NOCOUNT ON;
    UPDATE snd.Events
    SET QcState = (SELECT TOP(1) q.rowId FROM core.Qcstate AS q WHERE q.Label = 'Completed' ORDER BY q.rowId)
    FROM inserted AS i
             INNER JOIN snd.Events AS e ON i.EventId = e.EventId
    WHERE i.QcState IS NULL
END
go

-- move Events table cluster index to AnimalId, Date
--
-- need to drop foreign key constraints that reference the cluster index
EXEC core.fn_dropifexists 'EventNotes', 'snd', 'CONSTRAINT', 'FK_SND_EVENTNOTES_EVENTID'
EXEC core.fn_dropifexists 'EventData', 'snd', 'CONSTRAINT', 'FK_SND_EVENTDATA_EVENTID'
EXEC core.fn_dropifexists 'EventsCache', 'snd', 'CONSTRAINT', 'FK_EventsCache_EventId'
-- drop the snd.Events PK constraint (clustered index)
EXEC core.fn_dropifexists 'Events', 'snd', 'CONSTRAINT', 'PK_SND_EVENTS'

-- Add new snd.Events table PK constraint (non-clustered)
ALTER TABLE snd.Events ADD  CONSTRAINT PK_SND_EVENTS PRIMARY KEY NONCLUSTERED
    (
     EventId ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

-- Create new clustered index on snd.Events
EXEC core.fn_dropifexists 'Events', 'snd', 'INDEX', 'IDX_SND_EVENTS_SUBJECTID_DATE'
CREATE CLUSTERED INDEX IDX_SND_EVENTS_SUBJECTID_DATE ON snd.Events
    (
     SubjectId ASC,
     Date DESC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO


-- restore constraints
--
-- EventNotes
ALTER TABLE snd.EventNotes  WITH CHECK ADD  CONSTRAINT FK_SND_EVENTNOTES_EVENTID FOREIGN KEY(EventId)
    REFERENCES snd.Events (EventId)
GO

ALTER TABLE snd.EventNotes CHECK CONSTRAINT FK_SND_EVENTNOTES_EVENTID
GO

-- EventData
ALTER TABLE snd.EventData  WITH CHECK ADD  CONSTRAINT FK_SND_EVENTDATA_EVENTID FOREIGN KEY(EventId)
    REFERENCES snd.Events (EventId)
GO

ALTER TABLE snd.EventData CHECK CONSTRAINT FK_SND_EVENTDATA_EVENTID
GO

-- EventsCache
ALTER TABLE snd.EventsCache  WITH CHECK ADD  CONSTRAINT FK_EVENTSCACHE_EVENTID FOREIGN KEY(EventId)
    REFERENCES snd.Events (EventId)
GO

ALTER TABLE snd.EventsCache CHECK CONSTRAINT FK_EventsCache_EventId
GO