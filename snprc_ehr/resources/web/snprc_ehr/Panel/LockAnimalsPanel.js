/*
 * Copyright (c) 2013-2016 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.define('SNPRC_EHR.panel.LockAnimalsPanel', {
    extend: 'EHR.panel.LockAnimalsPanel',
    alias: 'widget.snprc-lockanimalspanel',

    getInstructionsText: function() {
        return 'The birth/arrival screen will be disabled as a default.  You must enable the form in order to: <br>'
            + '<ul><li>Get an Animal ID(s)</li><li>Secure the numbers for processing</li><li>Finish entering data on acquired numbers</li></ul><br>'
            + '<b>When you enable the form for data entry all others will automatically be blocked from using the form.</b> <br>'
            + 'Once you "Submit for Review" or "Save and Close", the birth/arrival form will be automatically be available for all other users. If you do not submit/save <i>please click the button below to exit data entry before leaving</i>, otherwise all other users will be permanently locked out. <br><br>'
            + 'If the birth/arrival form is unavailable and you believe it has been kept locked by mistake please first contact the person who locked the form. If they cannot be reached and it is a weekday please e-mail onprcitsupport@ohsu.edu with the subject "Priority 1 Work Stoppage: birth/arrival Form Locked". If it is a weekend please contact an RFO lead tech. Please take care not to request the birth/arrival form be unlocked unless you are confident the lock is in error, otherwise you will kick a user out of the birth/arrival form and prevent data entry.';
    }
});