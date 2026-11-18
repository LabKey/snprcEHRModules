/*
 * More Actions handlers for the study.BiocontainmentObservations dataset grid.
 * Registered in SNPRC_EHRModule.doStartupAfterSpringConfig().
 */
window.SNPRC_EHR = window.SNPRC_EHR || {};

SNPRC_EHR.BiocontainmentObservationButtons = {

    // Opens the print page for the observations selected in the grid (all pages, not just the visible one)
    printHandler: function (dataRegionName) {
        var dataRegion = LABKEY.DataRegions[dataRegionName];

        // Checked without a server call, so the window opens during the click and popup blockers allow it.
        // selectedCount is the server's count across all grid pages; getSelectionCount() covers the visible page.
        if (!(dataRegion.selectedCount > 0 || dataRegion.getSelectionCount() > 0)) {
            if (window.Ext4 && Ext4.Msg) Ext4.Msg.alert('Print Observations', 'Select one or more observations to print.');
            else window.alert('Select one or more observations to print.');
            return;
        }

        // The print page reads the same session selection, so a large selection does not end up in the URL
        window.open(LABKEY.ActionURL.buildURL('snprc_ehr', 'asiBioContainmentObservationsPrint', null, {
            selectionKey: dataRegion.selectionKey
        }), '_blank');
    }
};
