import React, { FC, memo, ReactNode, useState } from 'react';
import { Alert, ConfirmModal, resolveErrorMessage, SchemaQuery } from '@labkey/components';
import { deleteTableRow } from '../actions';

interface Props {
    onCancel: () => any;
    onComplete: (response: any) => any;
    id: number;
    table: string;
    schemaQuery: SchemaQuery;
    parentId?: number;
}

export const DeleteModal: FC<Props> = memo((props: Props) => {
    const [error, setError] = useState<ReactNode>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
    const [name, setName] = useState<string>('');
    const {onCancel, onComplete, id, table, schemaQuery, parentId} = props;

    const onConfirm = () => {

        setIsSubmitting(true);
        return deleteTableRow(schemaQuery.schemaName, schemaQuery.queryName, id, parentId)
            .then(onComplete)
            .catch(error => {
                console.error(error);
                setError(resolveErrorMessage(error, table, table + 's', 'delete'));
                setIsSubmitting(false);
            });

    };

    return (
        <ConfirmModal
            title={'Delete ' + table + '?'}
            onConfirm={onConfirm}
            onCancel={onCancel}
            confirmVariant={'danger'}
            confirmButtonText={'Yes, Permanently Delete'}
            cancelButtonText={'Cancel'}
            submitting={isSubmitting}
        >
            <p>{table} will be deleted. Do you want to proceed?</p>
            {error && <Alert>{error}</Alert>}
        </ConfirmModal>
    );
});