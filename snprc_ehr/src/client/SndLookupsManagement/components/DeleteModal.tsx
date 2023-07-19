import React, { FC, memo, ReactNode, useState } from 'react';
import { Alert, ConfirmModal, resolveErrorMessage, SchemaQuery } from '@labkey/components';
import { deleteTableRow } from '../actions';

interface Props {
    onCancel: () => any,
    onComplete: (response: any) => any,
    id: number,
    rowIdName: string,
    rowNameField: string,
    table: string,
    schemaQuery: SchemaQuery,
    row: any
}

export const DeleteModal: FC<Props> = memo((props: Props) => {
    const {onCancel, onComplete, id, table, schemaQuery, rowIdName, rowNameField, row} = props;
    const [error, setError] = useState<ReactNode>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

    /**
     * Callback for handling the delete operation when the button is pressed in the modal
     */
    const handleDelete = async () => {
        setIsSubmitting(true);
        let deleteRow = {};
        deleteRow[rowIdName] = id;

        return deleteTableRow(schemaQuery.schemaName, schemaQuery.queryName, deleteRow)
            .then(onComplete)
            .catch(error => {
                console.error(error);
                setError(resolveErrorMessage(error, table, table + 's', 'delete'));
                setIsSubmitting(false);
            });
    };

    return (
        <div className={'lookups-modal'}>
            <ConfirmModal
                title={'Delete ' + table + ' \'' + (row?.[rowNameField]) + '\'?'}
                onConfirm={row['IsInUse'] === 'true' ? onCancel : handleDelete}
                onCancel={onCancel}
                confirmVariant={row['IsInUse'] === 'true' ? 'primary' : 'danger'}
                confirmButtonText={row['IsInUse'] === 'true' ? 'Close' : 'Yes, Permanently Delete'}
                cancelButtonText={'Cancel'}
                submitting={isSubmitting}
            >
                {row['IsInUse'] !== 'true' && (
                    <p>{table} <b>'{row?.[rowNameField]}'</b> will be deleted. Do you want to proceed?</p>
                )
                }
                {row['IsInUse'] === 'true' &&
                        <Alert>{table} <b>'{row?.[rowNameField]}'</b> is in use by
                            a{table == 'Lookup' ? 'n Event' : ' Package'} and cannot be deleted.</Alert>

                }
                {error && <Alert>{error}</Alert>}
            </ConfirmModal>
        </div>
    );
});