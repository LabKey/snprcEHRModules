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
    parentIdName?: string
}

export const UpdateModal: FC<Props> = memo((props: Props) => {
    const {onCancel, onComplete, table, show, schemaQuery, rowIdName, rowNameField, parentIdName, row} = props;

    const [error, setError] = useState<ReactNode>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
    const [updateRow, setUpdateRow] = useState<any>([]);

    const handleUpdate = async (evt: any) => {
        evt.preventDefault();
        setIsSubmitting(true);
        setError(undefined);

        return updateTableRow(schemaQuery.schemaName, schemaQuery.queryName, row, Object.entries(updateRow))
            .then(onComplete)
            .catch(error => {
                console.error(error);
                setError(resolveErrorMessage(error));
                setIsSubmitting(false);
            });
    };


    return (
        <Modal show={show} onHide={onCancel}>
            <Modal.Header closeButton>
                <Modal.Title>Edit {table} '{row[rowNameField]}'</Modal.Title>
            </Modal.Header>
            <Modal.Body>
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
                                  finish={true}
                                  finishText={`Update ${table}`}
                                  isFinishing={isSubmitting}
                                  isFinishingText={`Updating ${table}s`}
                                  nextStep={handleUpdate}
                />
            </Modal.Footer>
        </Modal>
    );
});

