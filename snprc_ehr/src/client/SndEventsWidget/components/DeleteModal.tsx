import React, { FC, memo, ReactNode, useState } from 'react';
import { ConfirmModal, resolveErrorMessage } from '@labkey/components';
import { FetchAnimalEventResponse, fetchEvent } from '../actions/fetchEvent';
import { EventToSave, saveEvent } from '../actions/saveEvent';

interface Props {
    onCancel: () => any,
    onComplete: (message, status) => any,
    onError: (message) => any,
    eventId: string,
}
export const DeleteModal: FC<Props> = memo((props: Props) => {
    const {onCancel, onComplete, onError, eventId } = props;
    const [error, setError] = useState<ReactNode>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

    const handleDelete = async () => {
        setIsSubmitting(true);

        const event: FetchAnimalEventResponse | void = await fetchEvent(eventId).catch(error => {
            console.error(error);
            setError(resolveErrorMessage(error, "Event", "Event" + 's', 'delete'));
            setIsSubmitting(false);
        });

        if (event) {
            const deleteRequest: EventToSave = {
                eventId: event.eventId,
                date: event.date,
                projectIdRev: event.projectIdRev,
                subjectId: event.subjectId,
                qcState: event.qcState,
                note: '',
                extraFields: event.extraFields,
                eventData: []
            }

            saveEvent(deleteRequest)
                .then(t => {
                    if (t.success) {
                        onComplete('Successfully deleted Event', 'success');
                    } else {
                        onComplete('There was a problem deleting the Event', 'danger');
                    }

                })
                .catch(error => {
                    console.error(error);
                    setError(resolveErrorMessage(error, "Event", "Event" + 's', 'delete'));
                    setIsSubmitting(false);
                });
        }

    }

    return (
        <div className={'delete-modal'}>
            <ConfirmModal
                title={'Delete Event'}
                onConfirm={handleDelete}
                onCancel={onCancel}
                confirmVariant={'danger'}
                confirmButtonText={'Yes, Permanently delete Event'}
                cancelButtonText={'Cancel'}
                submitting={isSubmitting}
                >
                <p><b>Event for this Procedure will be permanently deleted. Do you want to proceed?</b></p>
            </ConfirmModal>
        </div>
    )
})