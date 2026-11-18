/*
 * More Actions handlers for the study.BiocontainmentObservations dataset grid.
 * Registered in SNPRC_EHRModule.doStartupAfterSpringConfig().
 */
window.SNPRC_EHR = window.SNPRC_EHR || {};

SNPRC_EHR.BiocontainmentObservationButtons = {

    // Opens the print page for the observations selected in the grid (all pages, not just the visible one)
    printHandler: function (dataRegionName) {
        var dataRegion = LABKEY.DataRegions[dataRegionName];

        var showMessage = function (title, msg) {
            if (window.Ext4 && Ext4.Msg) Ext4.Msg.alert(title, msg);
            else window.alert(msg);
        };

        dataRegion.getSelected({
            success: function (data) {
                if (!data || !data.selected || !data.selected.length) {
                    showMessage('Print Observations', 'Select one or more observations to print.');
                    return;
                }

                // The print page reads the same session selection, so a large selection does not end up in the URL
                window.open(LABKEY.ActionURL.buildURL('snprc_ehr', 'asiBioContainmentObservationsPrint', null, {
                    selectionKey: dataRegion.selectionKey
                }), '_blank');
            },
            failure: function (error) {
                showMessage('Error', (error && error.exception) || 'Unable to read the selected observations.');
            }
        });
    }
};
