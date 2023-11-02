import React, { FC, memo, useEffect, useMemo, useState } from 'react';
import { EventListingGridPanel } from './components/EventListingGridPanel';

export const SndEventsWidget: FC = memo(props => {
    return (
        <div>
            <EventListingGridPanel subjectID={1512572} />
        </div>
    )
})
