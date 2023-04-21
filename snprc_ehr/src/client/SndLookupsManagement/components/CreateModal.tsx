import React, { FC, memo, ReactNode, useState } from 'react';
import { Form, FormControl, Modal } from 'react-bootstrap';
import { Alert, resolveErrorMessage, SchemaQuery, WizardNavButtons } from '@labkey/components';
import { createTableRow } from '../actions';

interface Props {
    onCancel: () => any,
    onComplete: (response: any) => any,
    show: boolean,
    table: string,
    schemaQuery: SchemaQuery,
    parentId?: number
}

export const CreateModal: FC<Props> = memo((props: Props) => {
    const {show, onCancel, table, schemaQuery, parentId, onComplete} = props;
    const [name, setName] = useState<string>('');
    const [error, setError] = useState<string>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

    const create = () => {
        setIsSubmitting(true);
        setError(undefined);

        return createTableRow(schemaQuery.schemaName, schemaQuery.queryName, name, parentId)
            .then(onComplete)
            .catch(error => {
                console.error(error);
                setError(resolveErrorMessage(error));
                setIsSubmitting(false);
            });
    };

    const handleCreate = (evt: any): void => {
        const nameText = evt.target.value;
        setName(nameText);
    };

    const renderForm = (): ReactNode => {
        return (
            <>
                <div className="create-users-label-bottom">
                    {table} Name:
                    <FormControl
                        componentClass={'textarea'}
                        className={'form'}
                        id={'create-name-input'}
                        rows={1}
                        value={name || ''}
                        onChange={handleCreate}/>
                </div>

            </>
        );
    };

    return (
        <Modal show={show} onHide={onCancel}>
            <Modal.Header closeButton>
                <Modal.Title>Create New {table}</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                {renderForm()}
                {error && <Alert style={{marginTop: '10px'}}>{error}</Alert>}
            </Modal.Body>
            <Modal.Footer>
                <WizardNavButtons containerClassName={''}
                                  cancel={onCancel}
                                  finish={true}
                    //canFinish={valid}
                                  finishText={`Create ${table}`}
                                  isFinishing={isSubmitting}
                                  isFinishingText={`Creating ${table}s`}
                                  nextStep={create}
                />
            </Modal.Footer>
        </Modal>
    );
});