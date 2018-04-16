package org.labkey.snprc_ehr.snd.triggers;

import org.apache.commons.lang3.time.DateUtils;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.data.CompareType;
import org.labkey.api.data.Container;
import org.labkey.api.data.SimpleFilter;
import org.labkey.api.data.TableInfo;
import org.labkey.api.data.TableSelector;
import org.labkey.api.ehr.EHRDemographicsService;
import org.labkey.api.ehr.demographics.AnimalRecord;
import org.labkey.api.query.FieldKey;
import org.labkey.api.query.ValidationException;
import org.labkey.api.security.User;
import org.labkey.api.snd.AttributeData;
import org.labkey.api.snd.Event;
import org.labkey.api.snd.EventData;
import org.labkey.api.snd.EventTrigger;
import org.labkey.api.snd.Package;
import org.labkey.api.snd.TriggerAction;
import org.labkey.api.util.PageFlowUtil;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

public class BloodDrawTrigger implements EventTrigger
{

    public static class BloodInfo implements Comparable<BloodInfo>
    {
        private String _objectId;
        private Date _date;
        private double _quantity;

        public BloodInfo() {}

        public BloodInfo(String objectId, Date date, Double quantity)
        {
            _objectId = objectId;
            setDate(date);
            _quantity = quantity;
        }

        @Override
        public int compareTo(@NotNull BloodInfo o)
        {
            return getDate().compareTo(o.getDate());
        }

        public Date getDate()
        {
            return _date;
        }

        public String getObjectId()
        {
            return _objectId;
        }

        public double getQuantity()
        {
            return _quantity;
        }

        public void setObjectId(String objectId)
        {
            _objectId = objectId;
        }

        public void setDate(Date date)
        {
            //NOTE: consider whole-days only for blood volume calculations
            _date = date == null ? null : DateUtils.truncate(date, Calendar.DATE);
        }

        public void setQuantity(double quantity)
        {
            _quantity = quantity;
        }

        final long MILLIS_PER_DAY = 24 * 3600 * 1000;

        public boolean countsAgainstInterval(BloodInfo blood2, int intervalInDays)
        {
            Date date2 = blood2.getDate();
            if (date2 == null)
            {
                return false;
            }

            //NOTE: we expect BloodInfo to truncate these to nearest DATE
            long msDiff = getDate().getTime() - date2.getTime();
            long daysDiff = Math.round(msDiff / ((double) MILLIS_PER_DAY));

            return blood2.getQuantity() > 0 &&
                    getDate().compareTo(date2) >= 0 && daysDiff >= 0 && //must be before or same day as this draw
                    daysDiff < intervalInDays;  // and within the selected interval.  note: draws drop doff on the nth day, so use LT, not LTE
        }
    }

    private void validateTotalBloodDraws(Container c, User u, String id, Date date, int interval, double quantity, double weight, double maxAllowable, List<ValidationException> errors)
    {
        // Look forward and backward one interval for existing database records
        Calendar intervalStart = Calendar.getInstance();
        intervalStart.setTime(date);
        intervalStart.add(Calendar.DATE, (-1 * interval));  //draws drop off on the morning of the nth date
        intervalStart = DateUtils.truncate(intervalStart, Calendar.DATE);

        Calendar intervalStop = Calendar.getInstance();
        intervalStop.setTime(date);
        intervalStop.add(Calendar.DATE, interval);
        intervalStop = DateUtils.truncate(intervalStop, Calendar.DATE);

        SimpleFilter filter = new SimpleFilter(FieldKey.fromString("Id"), id);
        filter.addCondition(FieldKey.fromString("date"), intervalStart, CompareType.DATE_GTE);
        filter.addCondition(FieldKey.fromString("date"), intervalStop, CompareType.DATE_LTE);
        filter.addCondition(FieldKey.fromString("quantity"), null, CompareType.NONBLANK);
        filter.addCondition(FieldKey.fromString("countsAgainstVolume"), true);

        // Currently this queries study.blood. This is still pending tying SND with SNPRC study queries
        TableInfo ti = TriggerHelper.getTableInfo(c, u,"study", "Blood Draws", errors);
        if (ti == null || errors.size() > 0)
        {
            // if ti is null, there will be an error in errors
            return;
        }

        // All of the bloods that we need to consider
        List<BloodInfo> allBloods = new ArrayList<>();

        // Get records from the database in our date range that aren't part of the current transaction
        TableSelector tsdate = new TableSelector(ti, PageFlowUtil.set("objectid", "date", "quantity"), filter, null);
        allBloods.addAll(tsdate.getArrayList(BloodInfo.class));

        // Iterate over all of the blood records
        TreeSet<Double> overages = new TreeSet<>();
        for (BloodInfo blood1 : allBloods)
        {
            double bloodNextInterval = 0;

            // Find all of the other records within 30 days (looking forward only)
            for (BloodInfo blood2 : allBloods)
            {
                if (blood1.getObjectId().equals(blood2.getObjectId()))
                {
                    // Be sure to count the record itself
                    bloodNextInterval += blood1.getQuantity();
                }
                else
                {
                    if (blood1.countsAgainstInterval(blood2, interval))
                    {
                        bloodNextInterval += blood2.getQuantity();
                    }
                }
            }

            if (bloodNextInterval > maxAllowable)
            {
                overages.add(bloodNextInterval);
            }
        }

        //always report the most severe overage
        if (!overages.isEmpty())
        {
            errors.add(new ValidationException("Blood volume of " + quantity + " (" + overages.descendingSet().iterator().next() + " over " + interval + " days) exceeds the allowable volume of " + maxAllowable + " mL (weight: " + weight + " kg)", ValidationException.SEVERITY.WARN));
        }
    }

    @Nullable
    private Map<String, Object> getBloodInfoForSpecies(Container c, User u, String species, List<ValidationException> errors)
    {
        TableInfo ti = TriggerHelper.getTableInfo(c, u,"snprc_ehr", "species", errors);
        Map<String, Object> speciesBlood = null;
        if (errors.size() == 0 && ti != null)
        {
            // Cols to retrieve
            Set<String> cols = new HashSet<>();
            cols.add("blood_per_kg");
            cols.add("max_draw_pct");
            cols.add("blood_draw_interval");

            SimpleFilter filter = new SimpleFilter(FieldKey.fromParts("species_code"), species, CompareType.EQUAL);
            TableSelector ts = new TableSelector(ti, cols, filter, null);
            Map<String, Object>[] speciesBloodRows = ts.getMapArray();
            if (speciesBloodRows.length != 1)
            {
                errors.add(new ValidationException("Unable to determine the species " + species));
            }
            else
            {
                speciesBlood = ts.getMapArray()[0];
            }
        }

        return speciesBlood;
    }

    private void validateBloodDraw(Container c, User u, TriggerAction triggerAction)
    {
        Event event = triggerAction.getEvent();
        EventData eventData = triggerAction.getEventData();
        Package pkg = triggerAction.getSuperPackage().getPkg();

        AttributeData quantityAttribute = TriggerHelper.getAttribute("quantity", eventData, pkg);
        String subjectId = event.getSubjectId();
        Date date = event.getDate();

        // Should never hit this, but just to verify.
        if (subjectId == null || date == null)
        {
            // By default ValidationExceptions have severity level of Error
            event.setEventException(new ValidationException("There was a problem with the event data. Ensure animal id and date are filled in."));
            return;
        }

        if (quantityAttribute.getValue() == null)
        {
            eventData.setException(event, new ValidationException("Blood draw amount is missing."));
        }

        AnimalRecord ar = EHRDemographicsService.get().getAnimal(c, subjectId);
        if (ar == null)
        {
            // Although Error by default, you can explicitly declare Validation Exception as severity level Error
            event.setEventException(new ValidationException("Animal Id not found", ValidationException.SEVERITY.ERROR));
            return;
        }

        String species = ar.getSpecies();
        if (species == null)
        {
            event.setEventException(new ValidationException("Animal species not found"));
            return;
        }

        // Note: this gets the most recent weight from the db.  If weight is coming in with event, that will need to
        // be retrieved instead.
        Double weight = ar.getMostRecentWeight();
        if (weight == null)
        {
            eventData.setException(event, new ValidationException("Unknown most recent weight for animal " + subjectId
                    + ". Cannot calculate allowable blood draw value."));
            return;
        }

        List<ValidationException> errors = new ArrayList<>();
        Map<String, Object> bloodBySpecies = getBloodInfoForSpecies(c, u, species, errors);
        if (errors.size() > 0)
        {
            eventData.setException(event, errors.get(0));
            return;
        }

        if (bloodBySpecies == null)
        {
            eventData.setException(event, new ValidationException("Unable to determine allowable blood values for species " + species));
            return;
        }

        Double bloodPerKg = (Double)bloodBySpecies.get("blood_per_kg");
        Number interval = (Number)bloodBySpecies.get("blood_draw_interval"); // Note this is used in whole days only, decimals will be truncated
        Double maxDrawPct = (Double)bloodBySpecies.get("max_draw_pct");
        if (bloodPerKg == null || interval == null || maxDrawPct == null)
        {
            eventData.setException(event, new ValidationException("Unable to determine allowable blood values for species " + species));
            return;
        }

        double maxAllowable = Math.round((weight * bloodPerKg * maxDrawPct) * 100) / 100.0;
        if (Double.parseDouble(quantityAttribute.getValue()) > maxAllowable)
        {
            eventData.setException(event, new ValidationException("Unable to determine allowable blood values for species " + species, ValidationException.SEVERITY.WARN));
            return;
        }

        errors = new ArrayList<>();
        validateTotalBloodDraws(c, u, subjectId, date, interval.intValue(), Integer.parseInt(quantityAttribute.getValue()), weight, maxAllowable, errors);
    }

    @Override
    public void onInsert(Container c, User u, TriggerAction triggerAction, Map<String, Object> extraContext)
    {
        if (TriggerHelper.eventHasDataWithCategory("Cumulative Blood Draw", triggerAction.getEvent(), triggerAction.getTopLevelPkgs()))
        {
            validateBloodDraw(c, u, triggerAction);
        }
        else
        {
            triggerAction.getEventData().setException(triggerAction.getEvent(), new ValidationException("A blood draw was found without a cumulative blood draw."));
        }
    }

    @Override
    public void onUpdate(Container c, User u, TriggerAction triggerAction, Map<String, Object> extraContext)
    {
        onInsert(c, u, triggerAction, extraContext);
    }

    @Override
    public Integer getOrder()
    {
        return null;
    }
}
