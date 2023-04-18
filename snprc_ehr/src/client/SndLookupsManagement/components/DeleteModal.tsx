import React, { FC, ReactNode, useState } from 'react';
import { Alert, ConfirmModal } from '@labkey/components';
import { Utils } from '@labkey/api';

interface Props {
    onCancel: () => any;
    onComplete: (response: any) => any;
    ids: number[];
    table: string;
}

export const DeleteModal: FC<Props> = React.memo(props => {
    const [error, setError] = useState<ReactNode>(undefined);
    const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
    const { onCancel, ids, table } = props;
    const count = ids.length;

    const onConfirm = (): void => {
        const { ids, onComplete } = props;
        setIsSubmitting(true);
    }

    return(
        <ConfirmModal
            title={'Delete ' + Utils.pluralBasic(count, table) + '?'}
            onConfirm={onConfirm}
            onCancel={onCancel}
            confirmVariant={"danger"}
            confirmButtonText={"Yes, Permanently Delete"}
            cancelButtonText={"Cancel"}
            submitting={isSubmitting}
            >
            <p>{Utils.pluralBasic(count, table)} will be deleted. Do you want to proceed?</p>
            {error && <Alert>{error}</Alert>}
        </ConfirmModal>
    )
})