/*
 * Copyright (c) 2017-2018 LabKey Corporation
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
package org.labkey.snprc_ehr.enums;

/**
 * Created by lkacimi on 3/30/2017.
 */
public enum AssignmentFailureReason
{
    INVALID_ANIMAL_ID("Invalid Animal ID(s)"),
    DEAD_ANIMAL("Dead Animal(s)"),
    START_DATE_AFTER_DEATH("Animal was dead on the start date"),
    END_DATE_AFTER_DEATH("Animal was dead on the end date"),
    NOT_APPLICABLE_GENDER("Gender Mismatch"),
    ALREADY_IN_GROUP("Animal(s) already assigned to group"),
    ALREADY_IN_CATEGORY("Animal(s) already assigned to category"),
    FUTURE_DATE_NOT_ALLOWED("Future Dates not allowed"),
    NOT_APPLICABLE_SPECIES("Species Mismatch"),
    GROUP_DOES_NOT_EXIST("Animal group does not exist"),
    INVALID_DATE("Assignment start and end date must be between groups start and end date.");

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
