import React, { FC, memo, useState } from 'react';
import { Checkbox, ControlLabel, FormControl, FormGroup } from 'react-bootstrap';

interface Props {
    handleUpdate: (evt: any) => any,
    handleSetUpdateRow: (newRow: any) => void,
    rowIdName: string,
    parentIdName?: string,
    row: any
}

export const UpdateForm: FC<Props> = memo((props: Props) => {

    const {handleUpdate, handleSetUpdateRow, row, rowIdName, parentIdName} = props;
    const [newRow, setNewRow] = useState<any>([]);

    const onRowUpdate = async (evt: any, column: string) => {
        let thisRow = newRow;
        thisRow[column] = evt.target.type === 'checkbox' ? evt.target.checked : evt.target.value;
        setNewRow(thisRow);
        handleSetUpdateRow(newRow);
    };

    return (
        <div className={'update-users-label-bottom'}>
            {(Object.entries(row).map(column => {
                return (
                    <form onSubmit={handleUpdate}>
                        <FormGroup className={'form-group-create-update'} controlId={`form-${column[0]}-field}`}>
                            {!column[0].startsWith('_labkeyurl_') && !(column[0] === "IsInUse") && (
                                <div>
                                    <ControlLabel>{column[0]}:</ControlLabel>
                                    {(typeof column[1] !== 'boolean') && (
                                        <FormControl
                                            type={'textarea'}
                                            placeholder={`Enter ${column[0]}`}
                                            defaultValue={column[1] as string}
                                            onBlur={column[0] === rowIdName || column[0] === parentIdName ?
                                                (e) => (e) :
                                                (e) => onRowUpdate(e, column[0])}
                                            readOnly={row?.['IsInUse'] == 'true' || column[0] === rowIdName || column[0] === parentIdName}
                                        />
                                    )}
                                    {typeof column[1] === 'boolean' && (
                                        <Checkbox defaultChecked={column[1] as boolean}
                                                  label={column[0]}
                                                  onChange={(e) => onRowUpdate(e, column[0])}
                                        />
                                    )}
                                </div>
                            )}
                        </FormGroup>
                    </form>
                );
            }))}
        </div>
    );
});