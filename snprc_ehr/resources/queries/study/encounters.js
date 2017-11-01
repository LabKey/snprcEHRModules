/*
 * Copyright (c) 2015-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
// Note: <TableTitle> in snprc_ehr\resources\referenceStudy\datasets\datasets_metadata.xml was originally "Clinical Encounters."  It was
// changed to "Animal Events," which effectively circumvents the "Clinical Encounters.js" trigger script from being called. tjh

require("ehr/triggers").initScript(this);