package org.labkey.snprc_ehr.domain;

/**
 * Created by lkacimi on 4/18/2017.
 */
public class Veterinarian
{
    private Integer vetId;
    private Integer displayName;
    private String emailAddress;
    private String status;

    public Veterinarian()
    {

    }

    public Integer getVetId()
    {
        return vetId;
    }

    public void setVetId(Integer vetId)
    {
        this.vetId = vetId;
    }

    public Integer getDisplayName()
    {
        return displayName;
    }

    public void setDisplayName(Integer displayName)
    {
        this.displayName = displayName;
    }

    public String getEmailAddress()
    {
        return emailAddress;
    }

    public void setEmailAddress(String emailAddress)
    {
        this.emailAddress = emailAddress;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }
}
