import React, { FC, memo, useState } from 'react';
import { Checkbox, ControlLabel, Dropdown, FormControl, FormGroup } from 'react-bootstrap';
import Select from 'react-select';
import { getTableRow } from '../actions';

interface Props {
    handleUpdate: (evt: any) => any,
    handleSetUpdateRow: (newRow: any) => void,
    rowIdName: string,
    parentIdName?: string,
    row: any,
    rowCount?: number
}

export const UpdateForm: FC<Props> = memo((props: Props) => {

    const {handleUpdate, handleSetUpdateRow, row, rowIdName, parentIdName, rowCount} = props;
    const [newRow, setNewRow] = useState<any>([]);
    const [value, setValue] = useState<any>();

    const onRowUpdate = async (evt: any, column: string) => {
        let thisRow = newRow;
        console.log(evt)
        if (evt.value || evt.key === 0) {
            thisRow[column] = evt.value;
            setValue(evt.value ?? null);
        } else {
            thisRow[column] = evt.target.type === 'checkbox' ? evt.target.checked : evt.target.value;
        }
        setNewRow(thisRow);
        handleSetUpdateRow(newRow);
    };

    const renderList = (): any => {
        let numbers = [...new Array(rowCount).keys()].map(num => {
            return {label: num + 1, value: num + 1, key: num + 1};
        });
        numbers.unshift({label: null, value: null, key: 0});
        return numbers;
    }

    return (
        <div className={'update-users-label-bottom'}>
            {(Object.entries(row).map(column => {
                return (
                    <form onSubmit={handleUpdate}>
                        <FormGroup className={'form-group-create-update'} controlId={`form-${column[0]}-field}`}>
                            {!column[0].startsWith('_labkeyurl_') && !(column[0] === "IsInUse") && (
                                <div>
                                    <ControlLabel>{column[0]}:</ControlLabel>
                                    {(typeof column[1] !== 'boolean' && column[0] !== 'SortOrder') && (
                                        <FormControl
                                            type={'textarea'}
                                            placeholder={`Enter ${column[0]}`}
                                            defaultValue={column[1] as string}
                                            onBlur={column[0] === rowIdName || column[0] === parentIdName ?
                                                (e) => (e) :
                                                (e) => onRowUpdate(e, column[0])}
                                            readOnly={(row?.['IsInUse'] == 'true' && column[0] != 'SortOrder') || column[0] === rowIdName || column[0] === parentIdName}
                                        />
                                    )}
                                    {(column[0] === 'SortOrder') && (
                                        <Select
                                            className={"select-dropdown"}
                                            value={value ?? column[1]}
                                            placeholder={value ?? column[1] ?? "Select..."}
                                            options={renderList()}
                                            onChange={e => { onRowUpdate(e, column[0]); column[1] = undefined; }}
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