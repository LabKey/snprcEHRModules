package org.labkey.snprc_ehr;

import org.jetbrains.annotations.NotNull;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.DbScope;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.query.BatchValidationException;
import org.labkey.api.query.DuplicateKeyException;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.InvalidKeyException;
import org.labkey.api.query.QueryService;
import org.labkey.api.query.QueryUpdateService;
import org.labkey.api.query.QueryUpdateServiceException;
import org.labkey.api.query.UserSchema;
import org.labkey.api.security.User;
import org.labkey.api.util.GUID;
import org.labkey.snprc_ehr.domain.Counters;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public enum SNPRC_EHRSequencer
{
    ANIMALID("org.labkey.snprc_ehr.domain.AnimalId", 100);
    // new sequences are added here
    // example:
    // ANIMALID("org.labkey.snprc_ehr.domain.AnimalId", 0),
    // ADMITID("org.labkey.snprc_ehr.domain.AdmitId", 0),
    // MAINGID("org.labkey.snprc_ehr.domain.MatingId", 100);

    //private static final Logger _log = LogManager.getLogger(SNPRC_EHRSequencer.class);
    private final String sequenceName;
    private final int minValue;

    SNPRC_EHRSequencer(String name, int value)
    {
        sequenceName = name;
        minValue = value;
    }

    @NotNull
    public Integer getNextSequence(Container c, User u, boolean isMultipleSequenceRequest) throws RuntimeException
    {
        Counters sequenceValue;

        try (DbScope.Transaction transaction = SNPRC_EHRSchema.getInstance().getSchema().getScope().ensureTransaction())
        {
            UserSchema schema = QueryService.get().getUserSchema(u, c, "snprc_ehr");
            TableInfo ti = schema.getTable("Counters");
            if (ti == null) throw new SQLException("SNPRC_EHRSenquencer: TableInfo is null");
            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts(Counters.COUNTERS_NAME), this.sequenceName, CompareType.EQUAL);
            filter.addCondition(FieldKey.fromString(Counters.COUNTERS_CONTAINER), c, CompareType.EQUAL);

            List<Counters> counters = new TableSelector(ti, filter, null).getArrayList(Counters.class);

            int numRows = counters.size();
            if (numRows > 0)
            {
                if (isMultipleSequenceRequest)
                {
                    // get the largest counter value
                    sequenceValue = counters.stream().max(Comparator.comparing(v -> v.getValue())).get();
                }
                else
                {
                    // get lowest counter value
                    sequenceValue = counters.stream().min(Comparator.comparing(v -> v.getValue())).get();
                }
            }
            else
            {
                // counter doesn't exist - need to initialize it
                sequenceValue = new Counters(c.toString(), this.sequenceName, this.minValue);
                sequenceValue.setObjectId(GUID.makeGUID());
            }

            List<Map<String, Object>> rowsList = new ArrayList<>(); // used for CRUD operations

            QueryUpdateService qus = ti.getUpdateService();
            if (qus == null) throw new SQLException("SNPRC_EHRSenquencer: Query update service is null");

            // if the sequence doesn't exist, initialize it with minimum value
            if (numRows == 0)
            {
                BatchValidationException batchErrors = new BatchValidationException();
                Map<String, Object> dataMap = sequenceValue.toMap();
                rowsList.add(dataMap);

                qus.insertRows(u, c, rowsList, batchErrors, null, null);
                if (batchErrors.hasErrors()) throw batchErrors;
            }
            // if the sequence has more than one value in the table then delete the one returned
            else if (numRows > 1 && !isMultipleSequenceRequest)
            {
                Map<String, Object> row = new HashMap<>();
                row.put(Counters.COUNTERS_ROW_ID, sequenceValue.getRowId());

                qus.deleteRows(u, c, Collections.singletonList(row), null, null);
            }
            // there is only one counter, so it needs to be incremented
            else
            {
                // increment counter
                sequenceValue.setValue(sequenceValue.getValue() + 1);

                Map<String, Object> pkMap = new HashMap<>();
                pkMap.put(Counters.COUNTERS_ROW_ID, sequenceValue.getRowId());
                List<Map<String, Object>> pk = new ArrayList<>();
                pk.add(pkMap);

                Map<String, Object> dataMap = sequenceValue.toMap();
                rowsList.add(dataMap);

                qus.updateRows(u, c, rowsList, pk, null, null);
            }

            transaction.commit();
        }
        catch (SQLException | QueryUpdateServiceException | BatchValidationException | InvalidKeyException | DuplicateKeyException e)
        {
            throw new RuntimeException(e);
        }

        // return counter
        return sequenceValue.getValue();
    }

    // this is a large block of code to synchronize - consider refactoring it in the future
    @NotNull
    public Integer getNext(Container c, User u, boolean isMultipleSequenceRequest)
    {
        synchronized (this)
        {
            return getNextSequence(c, u, isMultipleSequenceRequest);
        }
    }

    @NotNull
    public Integer getNext(Container c, User u)
    {
        return getNext(c, u, false);
    }
}
