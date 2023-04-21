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
    schemaQuery: SchemaQuery,
    parentId?: number
}

export const UpdateModal: FC<Props> = memo((props: Props) => {
    const {onCancel, onComplete, id, table, show, schemaQuery, parentId, rowIdName} = props;

    const [error, setError] = useState<ReactNode>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
    const [name, setName] = useState<string>('');

    const update = () => {
        setIsSubmitting(true);
        setError(undefined);

        return updateTableRow(schemaQuery.schemaName, schemaQuery.queryName, id, name, parentId)
            .then(onComplete)
            .catch(error => {
                console.error(error);
                setError(resolveErrorMessage(error));
                setIsSubmitting(false);
            });
    };

    const handleUpdate = (evt: any): void => {
        //const nameText = evt.target.value;
        //setName(nameText);
    };

    return (
        <Modal show={show} onHide={onCancel}>
            <Modal.Header closeButton>
                <Modal.Title>Edit {table} {name}</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                <UpdateForm
                    table={table}
                    schemaQuery={schemaQuery}
                    id={id}
                    rowIdName={rowIdName}
                    parentId={parentId}
                    onChange={handleUpdate}
                />
                {error && <Alert style={{marginTop: '10px'}}>{error}</Alert>}
            </Modal.Body>
            <Modal.Footer>
                <WizardNavButtons containerClassName={''}
                                  cancel={onCancel}
                                  finish={true}
                    //canFinish={valid}
                                  finishText={`Update ${table}`}
                                  isFinishing={isSubmitting}
                                  isFinishingText={`Updating ${table}s`}
                                  nextStep={update}
                />
            </Modal.Footer>
        </Modal>
    );
});

