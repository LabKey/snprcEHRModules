
ALTER TRIGGER snd.ti_after_Events ON snd.Events FOR INSERT AS
BEGIN
    SET NOCOUNT ON;
UPDATE snd.Events
SET QcState = (SELECT TOP(1) q.rowId FROM core.DataStates AS q WHERE q.Label = 'Completed' ORDER BY q.rowId)
    FROM inserted AS i
             INNER JOIN snd.Events AS e ON i.EventId = e.EventId
WHERE i.QcState IS NULL
END
go