/**
 * Will attempt to convert all records to the QCState 'Review Required' and submit the form.
 */
EHR.DataEntryUtils.registerDataEntryFormButton('SNPRC_REVIEW', {
    text: 'Submit for SNPRC Review',
    name: 'snprc_review',
    requiredQC: 'Review Required',
    targetQC: 'Review Required',
    errorThreshold: 'WARN',
    //successURL: LABKEY.ActionURL.getParameter('srcURL') || LABKEY.ActionURL.buildURL('ehr', 'enterData.view'),
    successURL: LABKEY.ActionURL.getParameter('srcURL') || LABKEY.ActionURL.getParameter('returnUrl') || LABKEY.ActionURL.getParameter('returnURL') || LABKEY.ActionURL.buildURL('ehr', 'enterData.view'),
    disabled: true,
    itemId: 'reviewBtn',
    disableOn: 'WARN',
    handler: function (button) {

        var panel = button.up('ehr-dataentrypanel');
        Ext4.Msg.confirm('Submit Form for Review', 'You are about to submit this form for review.  Do you want to do this?', function (b) {
            if (b == 'yes')
                this.onSubmit(button);
        }, this);
    }
});
