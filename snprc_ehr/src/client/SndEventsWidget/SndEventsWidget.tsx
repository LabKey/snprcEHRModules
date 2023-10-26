import React, { useEffect, useState } from 'react';

export const SndEventsWidget = () => {
    const [subjectId, setSubjectId] = useState('');

    useEffect(() => {
        const widget = document.createElement('script');

        widget.src = "/labkey/snprc_mobile/app/widget.js";
        widget.type = "application/javascript";
        widget.async = true;
        document.body.appendChild(widget);
    }, [])

    const updateReport = () => {

    }

    const handleKeyDown = (event) => {
        if (event.keyCode === 13) {
            updateReport();
        }
    }

    return (
        <div id="snprc-inputs">
            <label htmlFor="subject-id">
                SubjectID:{' '}
                <input
                    id="subject-id"
                    type="text"
                    value={subjectId}
                    onChange={(e) => setSubjectId(e.target.value)}
                    onKeyDown={handleKeyDown}
                    />
            </label>
            <button id="update-report" onClick={updateReport}>
                Enter
            </button>
            <div id="procedure-entry-widget" data-subject-id={subjectId}></div>
        </div>
    )
}