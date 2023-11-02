import React, { useEffect, useState } from 'react';

export const ProcedureEntryModal = () => {
    const [eventId, setEventId] = useState('');

    useEffect(() => {
        const widget = document.createElement('script');

        widget.src = "/labkey/snprc_mobile/app/widget.js";
        widget.type = "application/javascript";
        widget.async = true;
        document.body.appendChild(widget);
    }, [])

    const updateReport = () => {
        const ProcedureEntryWidget = document.getElementById('procedure-entry-widget')
        ProcedureEntryWidget.setAttribute('data-event-id', eventId)
    }

    return (
        <div id ="fake-root">
            <div id="procedure-entry-widget" data-event-id={eventId}></div>
        </div>
    )
}