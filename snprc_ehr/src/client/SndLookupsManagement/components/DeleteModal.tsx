import React, { FC, memo, ReactNode, useState } from 'react';
import { Alert, ConfirmModal, resolveErrorMessage, SchemaQuery } from '@labkey/components';
import { deleteTableRow } from '../actions';

interface Props {
    onCancel: () => any,
    onComplete: (response: any) => any,
    id: number,
    rowIdName: string,
    table: string,
    schemaQuery: SchemaQuery,
}

export const DeleteModal: FC<Props> = memo((props: Props) => {
    const [error, setError] = useState<ReactNode>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

    const {onCancel, onComplete, id, table, schemaQuery, rowIdName} = props;

    const onConfirm = async () => {
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
        <ConfirmModal
            title={'Delete ' + table + ' \'' + id + '\'?'}
            onConfirm={onConfirm}
            onCancel={onCancel}
            confirmVariant={'danger'}
            confirmButtonText={'Yes, Permanently Delete'}
            cancelButtonText={'Cancel'}
            submitting={isSubmitting}
        >
            {<p>{table} '{id}' will be deleted. Do you want to proceed?</p>}
            {error && <Alert>{error}</Alert>}
        </ConfirmModal>
    );
});