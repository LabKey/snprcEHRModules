import React, { FC, memo, useState } from 'react';
import { EventListingGridPanel } from './components/EventListingGridPanel';
import './styles/sndEventsWidget.scss'

interface Props {
    subjectID: string
}

export const SndEventsWidget: FC<Props> = memo((props: Props) => {
    const {subjectID} = props;
    return (
        <div>
            <EventListingGridPanel subjectID={subjectID} />
        </div>
    )
})
