import React, { FC, memo, ReactNode, useEffect, useState } from 'react';
import { Alert, resolveErrorMessage, SchemaQuery, WizardNavButtons } from '@labkey/components';
import { Modal } from 'react-bootstrap';
import { getTableRow, updateTableRow } from '../actions';
import { UpdateForm } from './UpdateForm';

interface Props {
    onCancel: () => any,
    onComplete: (response: any) => any,
    id: number,
    show: boolean,
    table: string,
    rowIdName: string,
    schemaQuery: SchemaQuery,
    parentId?: number,
    parentIdName?: string
}

export const UpdateModal: FC<Props> = memo((props: Props) => {
    const {onCancel, onComplete, id, table, show, schemaQuery, parentId, rowIdName, parentIdName} = props;

    const [error, setError] = useState<ReactNode>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
    const [row, setRow] = useState<any>([]);
    const [updateRow, setUpdateRow] = useState<any>([]);

    useEffect(() => {
        const fetchData = async () => {
            await getRow();
        };
        fetchData();
    }, []);

    const getRow = async () => {
        const tableRow = await getTableRow(schemaQuery.schemaName, schemaQuery.queryName, id, parentId);
        setRow(tableRow['rows'].find(row => row[rowIdName] === id));
    };

    const update = () => {
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

    const handleUpdate = (newRow: any): void => {
        setUpdateRow(newRow);
        console.log(updateRow);
    };

    return (
        <Modal show={show} onHide={onCancel}>
            <Modal.Header closeButton>
                <Modal.Title>Edit {table} '{(parentId ? row['Value'] : row['SetName'])}'</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                <UpdateForm
                    handleUpdate={handleUpdate}
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
                                  nextStep={update}
                />
            </Modal.Footer>
        </Modal>
    );
});

