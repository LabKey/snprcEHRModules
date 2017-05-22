package org.labkey.snprc_ehr.enums;

/**
 * Created by lkacimi on 3/30/2017.
 */
public enum AssignmentFailureReason
{
    INVALID_ANIMAL_ID("Invalid Animal ID(s)"),
    DEAD_ANIMAL("Dead Animal(s)"),
    NOT_APPLICABLE_GENDER("Gender Mismatch"),
    ALREADY_IN_GROUP("Animal(s) already assigned to group"),
    ALREADY_IN_CATEGORY("Animal(s) already assigned to category"),
    FUTURE_DATE_NOT_ALLOWED("Future Dates not allowed"),
    NOT_APPLICABLE_SPECIES("Species Mismatch");

    private String reason;

    AssignmentFailureReason(String reason)
    {
        this.reason = reason;
    }


    @Override
    public String toString()
    {
        return this.reason;
    }
}
