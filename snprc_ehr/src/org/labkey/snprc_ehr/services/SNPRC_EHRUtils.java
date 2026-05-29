/*
 * Copyright (c) 2023-2026 LabKey Corporation
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
