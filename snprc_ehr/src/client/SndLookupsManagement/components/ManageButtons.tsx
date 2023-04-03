import React, { ComponentType, FC, useState } from 'react';
import { QueryModel, RequiresModelAndActions } from '@labkey/components';
import { Button } from 'react-bootstrap';

interface Props {
    id: string,
    AdditionalGridButtons?: ComponentType<RequiresModelAndActions>,
    model: QueryModel
}

export const ManageButtons: FC<Props & RequiresModelAndActions> = React.memo(props => {
    const { id, model } = props;
    const [showDialog, setShowDialog] = useState<string>('');

    const toggleDialog = (name: string, requiresSelection = false) => {
        if (requiresSelection && model.hasSelections) {
            setShowDialog(undefined);
        } else {
            setShowDialog(name);
        }
    }
    return (
        <div className='btn-group'>
            {/*{<Button bsStyle={'success'} onClick={}>Create</Button>}*/}
        </div>
    )
})