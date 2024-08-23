import React, { FC, memo, useState, useEffect } from 'react';
import { EventListingGridPanel } from './components/EventListingGridPanel';
import './styles/sndEventsWidget.scss';
import { FormGroup, ControlLabel, FormControl } from 'react-bootstrap';
import { getMultiRow } from './actions/actions';
import { Alert } from '@labkey/components';

interface Props {
    filterConfig: any,
    hasReadPermission: boolean,
    hasWritePermission: boolean
}

export const SndEventsWidget: FC<Props> = memo((props: Props) => {
    const {filterConfig, hasReadPermission, hasWritePermission} = props;
    const [subjectIds, setSubjectIds] = useState<string[]>(['']);
    const [message, setMessage] = useState<string>(undefined);
    const [status, setStatus] = useState<string>(undefined);

    useEffect(() => {
        (async () => {
            if (hasReadPermission && filterConfig !== undefined && filterConfig.length != 0) {
                await getSubjectIdsFromFilters(filterConfig, setSubjectIds);
            }
        })();
    }, []);


    const handleEnter = (e) => {
        setSubjectIds(e.target.value.split(';'));
    };

    const handleError = (message: string) => {
        setMessage(message);
        setStatus("danger");
        window.setTimeout(() => setMessage(undefined), 30000);
    };

    const handleUpdateResponse = (message: string, status: string) => {
        setMessage(message);
        setStatus(status);
        window.setTimeout(() => setMessage(undefined), 30000);
    };

    const form = () => {
        return (
            <div>
                <form onSubmit={handleEnter}>
                    <FormGroup className={'subjectId-form'} htmlFor={'standaloneId'}>
                        <ControlLabel>Subject ID: </ControlLabel>
                        <FormControl id={'subjectIdForm'}
                                     name={'standaloneId'}
                                     type={'text'}
                                     placeholder={`Enter Subject ID`}
                                     required={true}
                                     onChange={(e: any) => setSubjectIds(e.target.value.split(';'))}
                        />
                    </FormGroup>
                </form>
            </div>
        );
    };

    return (
        <div>
            {!hasReadPermission && (
                <Alert>User Does not have permission to view this panel</Alert>
            )}
            {hasReadPermission && (filterConfig === undefined || filterConfig.length == 0) && (
                form()
            )
            }
            {hasReadPermission && (filterConfig !== undefined && filterConfig.length != 0 && filterConfig?.filters.inputType === 'none') && (
                <Alert>'Entire Database' filter is not supported for this query.</Alert>
            )}
            {hasReadPermission && subjectIds[0] === 'none' && (
                <Alert>No animals were found for filter selections</Alert>
            )}
            {message && (
                <Alert bsStyle={status}>{message}</Alert>
            )}
            {hasReadPermission && subjectIds && (
                <EventListingGridPanel subjectIDs={subjectIds} onChange={handleUpdateResponse} onError={handleError} hasWritePermission={hasWritePermission}/>
            )}

        </div>
    );
});

const getSubjectIdsFromFilters = async (filterConfig, handleSetSubjectIds) => {
    const subjectIds = [];
    const filters = filterConfig.filters;
    if (filters.inputType === 'roomCage' && filters.room !== null) {
        const rooms = filters.room.split(',');
        let ids: string[];
        try {
            ids = (await getMultiRow('study', 'demographicsCurLocation', 'room', rooms, []))['rows'].map(a => a.Id);
        }
        catch (err) {
            console.log(err);
        }
        handleSetSubjectIds(ids.length ? ids : ['none']);
    } else if (filters.inputType === 'multiSubject') {
        const ids = filters.nonRemovable['0'] ? filters.nonRemovable['0'].value : ['none'];
        handleSetSubjectIds(Array.isArray(ids) ? ids : [ids]);
    } else if (filters.inputType === 'singleSubject') {
        const ids = filters.subjects;
        subjectIds.push(ids);
        handleSetSubjectIds(subjectIds);
    }
};