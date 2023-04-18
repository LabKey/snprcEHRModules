import React, { FC, ReactNode, useState } from 'react';
import { FormControl, Modal } from 'react-bootstrap';
import { Alert, WizardNavButtons } from '@labkey/components';

interface Props {
    onCancel: () => any;
    onComplete: (response: any) => any;
    show: boolean;
    table: string;
}

export const CreateModal: FC<Props> = React.memo(props => {
    const { show, onCancel, table } = props;
    const [name, setName] = useState<string>('');
    const [error, setError] = useState<string>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

    const create = () => {

    }
    const handleCreate = (evt: any): void => {
        const nameText = evt.target.value;
        setName(nameText);
    }

    const renderForm = (): ReactNode => {
        return (
            <>
            <div className="create-users-label-bottom">
                Enter one or more names for new {table}, each on its own line:
            </div>
            <FormControl
                componentClass={"textarea"}
                className={"form-control"}
                id={"create-name-input"}
                rows={5}
                value={name || ''}
                onChange={handleCreate} />
        </>
        )
    }

    return(
        <Modal show={show} onHide={onCancel}>
            <Modal.Header closeButton>
                <Modal.Title>Create New {table}</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                {renderForm()}
                {error && <Alert style={{ marginTop: '10px' }}>{error}</Alert>}
            </Modal.Body>
            <Modal.Footer>
                <WizardNavButtons containerClassName={""}
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
    )
})