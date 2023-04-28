import React, { FC, memo, ReactNode, useCallback, useEffect, useState } from 'react';
import { ControlLabel, FormControl, FormGroup, Modal } from 'react-bootstrap';
import { Alert, resolveErrorMessage, SchemaQuery, WizardNavButtons } from '@labkey/components';
import { createTableRow } from '../actions';

interface Props {
    onCancel: () => any,
    onComplete: (response: any) => any,
    show: boolean,
    table: string,
    schemaQuery: SchemaQuery,
    row: any,
    parentId?: number,
}

export const CreateModal: FC<Props> = memo((props: Props) => {
    const {show, onCancel, table, schemaQuery, parentId, onComplete, row} = props;
    const [name, setName] = useState<string>('');
    const [error, setError] = useState<string>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

    const handleCreate = (evt: any) => {
        evt.preventDefault();
        setIsSubmitting(true);
        setError(undefined);

        return createTableRow(schemaQuery.schemaName, schemaQuery.queryName, name, parentId)
            .then(onComplete)
            .catch(error => {
                console.error(error);
                setError(resolveErrorMessage(error));
                setIsSubmitting(false);
            });
    }

    const renderForm = (): ReactNode => {
        return (
            <>
                <div>
                    <form onSubmit={handleCreate}>
                    <FormGroup className={"form-group-create-update"} htmlFor={'formNameField'}>
                        <ControlLabel>Name: </ControlLabel>
                        <FormControl id={'create-form'} name={'formNameField'} type={'text'} placeholder={`Enter ${table} Name`} required={true}
                                     onChange={(e: any) => setName(e.target.value)} ></FormControl>
                    </FormGroup>
                    </form>
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
                                  finishText={`Create ${table}`}
                                  isFinishing={isSubmitting}
                                  isFinishingText={`Creating ${table}s`}
                                  nextStep={handleCreate}
                />
            </Modal.Footer>
        </Modal>
    );
});