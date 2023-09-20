import React, { FC, memo, ReactNode, useState } from 'react';
import { Alert, resolveErrorMessage, SchemaQuery, WizardNavButtons } from '@labkey/components';
import { Modal } from 'react-bootstrap';
import { updateTableRow } from '../actions';
import { UpdateForm } from './UpdateForm';

interface Props {
    onCancel: () => any,
    onComplete: (response: any) => any,
    id: number,
    show: boolean,
    table: string,
    rowIdName: string,
    rowNameField: string,
    schemaQuery: SchemaQuery,
    row: any,
    parentIdName?: string,
    parentId?: number
}

export const UpdateModal: FC<Props> = memo((props: Props) => {
    const {
        onCancel,
        onComplete,
        table,
        show,
        schemaQuery,
        rowIdName,
        rowNameField,
        parentIdName,
        parentId,
        row
    } = props;

    const [error, setError] = useState<ReactNode>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
    const [updateRow, setUpdateRow] = useState<any>([]);

    /**
     * Callback for handling the update operation performed with the form data in the modal when the confirm button is pressed
     * @param evt
     */
    const handleUpdate = (evt: any) => {
        evt.preventDefault();
        setIsSubmitting(true);
        setError(undefined);
        updateTableRow(schemaQuery.schemaName, schemaQuery.queryName, row, Object.entries(updateRow))
            .then(onComplete)
            .catch(error => {
                console.error(error);
                setError(resolveErrorMessage(error));
                setIsSubmitting(false);
            });
    };

    return (
        <Modal show={show} onHide={onCancel} className={'lookups-modal'}>
            <Modal.Header closeButton>
                <Modal.Title>Edit {table} '{row?.[rowNameField]}'</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                {row?.['IsInUse'] == 'true' &&
                        <Alert className={'edit-alert'}>{table} <b>'{row?.[rowNameField]}'</b> is in use by
                            a{parentId ? 'n Event' : ' Package'}. Some fields may not be changed.</Alert>}
                <UpdateForm
                    handleUpdate={handleUpdate}
                    handleSetUpdateRow={e => setUpdateRow(e)}
                    row={row}
                    rowIdName={rowIdName}
                    parentIdName={parentIdName}
                />
                {error && <Alert style={{marginTop: '10px'}}>{error}</Alert>}
            </Modal.Body>
            <Modal.Footer>
                <WizardNavButtons containerClassName={''}
                                  cancel={onCancel}
                                  finish={table == 'Lookup' || row?.['IsInUse'] == 'false'}
                                  finishText={`Update ${table}`}
                                  isFinishing={isSubmitting}
                                  isFinishingText={`Updating ${table}s`}
                                  nextStep={table == 'Lookup' || row?.['IsInUse'] == 'false' ? handleUpdate : onCancel}
                />
            </Modal.Footer>
        </Modal>
    );
});