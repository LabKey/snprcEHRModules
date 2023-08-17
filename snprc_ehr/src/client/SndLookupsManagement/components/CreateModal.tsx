import React, { FC, memo, useState } from 'react';
import { ControlLabel, FormControl, FormGroup, Modal } from 'react-bootstrap';
import { Alert, resolveErrorMessage, SchemaQuery, WizardNavButtons } from '@labkey/components';
import { createTableRow } from '../actions';

interface Props {
    onCancel: () => any,
    onComplete: (response: any) => any,
    show: boolean,
    table: string,
    schemaQuery: SchemaQuery,
    parentId?: number,
}

export const CreateModal: FC<Props> = memo((props: Props) => {
    const {show, onCancel, table, schemaQuery, parentId, onComplete} = props;
    const [name, setName] = useState<string>('');
    const [error, setError] = useState<string>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

    /**
     * Callback for handling the create operation from the forms in the modal when the button is pressed
     * @param evt
     */
    const handleCreate = (evt: any) => {
        evt.preventDefault();
        setIsSubmitting(true);
        setError(undefined);

        createTableRow(schemaQuery.schemaName, schemaQuery.queryName, name, parentId)
            .then(onComplete)
            .catch(error => {
                console.error(error);
                setError(resolveErrorMessage(error));
                setIsSubmitting(false);
            });
    };

    /**
     * Render the form that will be used for the create operation, using just the name value on the table
     */
    const renderForm = () => {
        return (
            <div>
                <form onSubmit={handleCreate}>
                    <FormGroup className={'form-group-create-update'} htmlFor={'formNameField'}>
                        <ControlLabel>Name: </ControlLabel>
                        <FormControl id={'create-form'}
                                     name={'formNameField'}
                                     type={'text'}
                                     placeholder={`Enter ${table} Name`}
                                     required={true}
                                     onChange={(e: any) => setName(e.target.value)}
                        />
                    </FormGroup>
                </form>
            </div>
        );
    };

    return (
        <Modal show={show} onHide={onCancel} className={'lookups-modal'}>
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
                                  isFinishingText={`Creating ${table}`}
                                  nextStep={handleCreate}
                />
            </Modal.Footer>
        </Modal>
    );
});