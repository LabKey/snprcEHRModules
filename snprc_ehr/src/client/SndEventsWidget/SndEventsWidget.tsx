import React, { FC, memo, useState } from 'react';
import { EventListingGridPanel } from './components/EventListingGridPanel';

export const SndEventsWidget: FC = memo(props => {

    const [subjectID, setSubjectID] = useState<string>('42409');

    return (
        <div>
            <EventListingGridPanel subjectID={subjectID} />
        </div>
    )
})
