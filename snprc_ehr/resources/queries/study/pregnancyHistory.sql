/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

  SELECT edc.id ,
		edc.date,
		edc.sire,
    edc.termDate,
    edc.termCode.description,
    edc.confirmDate,
		edc.lastObscanDate

 From study.pregnancyConfirmation edc
 where edc.qcstate.publicdata = true and edc.termCode <=28

