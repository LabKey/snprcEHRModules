import React, { FC, memo, useState, useEffect } from 'react';
import { EventListingGridPanel } from './components/EventListingGridPanel';
import './styles/sndEventsWidget.scss'
import { FormGroup, ControlLabel, FormControl } from 'react-bootstrap'
import { getMultiRow } from './actions';

interface Props {
    filterConfig: any
}

export const SndEventsWidget: FC<Props> = memo((props: Props) => {
    const {filterConfig} = props;
    const [subjectIds, setSubjectIds] = useState<string[]>(['']);

    useEffect(() => {
        (async () => {
            if (filterConfig !== undefined && filterConfig.length != 0) {
                await getSubjectIdsFromFilters(filterConfig, setSubjectIds);
            }
        })();
    }, [])


    const handleEnter = (e) => {
        setSubjectIds(e.target.value.split(";"))
    }

    const form = () => {
        return(
            <div>
                <form onSubmit={handleEnter}>
                    <FormGroup className={'subjectId-form'} htmlFor={'standaloneId'}>
                        <ControlLabel>Subject ID: </ControlLabel>
                        <FormControl id={'subjectIdForm'}
                                     name={'standaloneId'}
                                     type={'text'}
                                     placeholder={`Enter Subject ID`}
                                     required={true}
                                     onChange={(e: any) => setSubjectIds(e.target.value.split(";"))}
                        />
                    </FormGroup>
                </form>
            </div>
        )
    }

    return (
        <div>
            {(filterConfig === undefined || filterConfig.length == 0) && (
                form()
            )
            }
            <EventListingGridPanel subjectIDs={subjectIds} />
        </div>
    )
})

const getSubjectIdsFromFilters = async (filterConfig, handleSetSubjectIds) => {
    const subjectIds = [];
    const filters = filterConfig.filters;
    if (filters.inputType === 'roomCage' && filters.room !== null) {
        const rooms = filters.room.split(',');
        const ids = (await getMultiRow('study', 'demographicsCurLocation', 'room', rooms, []))['rows'].map(a => a.Id);
        handleSetSubjectIds(ids)
    } else if (filters.inputType === 'multiSubject') {
        const ids = filters.nonRemovable['0'].value;
        handleSetSubjectIds(ids);
    } else if (filters.inputType === 'singleSubject') {
        const ids = filters.subjects;
        subjectIds.push(ids);
        handleSetSubjectIds(subjectIds);
    }
}