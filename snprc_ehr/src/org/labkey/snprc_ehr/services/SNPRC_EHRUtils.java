package org.labkey.snprc_ehr.services;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class SNPRC_EHRUtils
{
    private SNPRC_EHRUtils()
    {
        // prevent external construction with a private default constructor
    }

    private static final SNPRC_EHRUtils _instance = new SNPRC_EHRUtils();

    public static SNPRC_EHRUtils get()
    {
        return _instance;
    }

    // Create SQL date/time string for current date/time with an offset in minutes
    public String getQueryDateTime(int addMinutes)
    {
        // Add (or subtract) minutes from current date/time
        LocalDateTime currentDateTime = LocalDateTime.now();
        LocalDateTime plusMinutes = currentDateTime.plusMinutes(addMinutes);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        return plusMinutes.format(formatter);
    }

}
