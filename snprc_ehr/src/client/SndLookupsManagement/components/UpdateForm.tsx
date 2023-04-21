import { getTableRow } from '../actions';
import { SchemaQuery } from '@labkey/components';
import React, { FC, memo, ReactNode, useEffect, useState } from 'react';
import { FormControl } from 'react-bootstrap';

interface Props {
    table: string,
    onChange: (evt: any) => void,
    schemaQuery: SchemaQuery,
    id?: number,
    rowIdName: string,
    parentId?: number
}

export const UpdateForm: FC<Props> = memo((props: Props) => {

    const {schemaQuery, id, parentId, rowIdName, onChange} = props;
    const [row, setRow] = useState<any>([]);

    useEffect(() => {
        const fetchData = async () => {
            await getRow();
        };
        fetchData();
    }, []);

    const getRow = async () => {
        const tableRow = await getTableRow(schemaQuery.schemaName, schemaQuery.queryName, id, parentId);
        setRow(tableRow['rows'].find(row => row[rowIdName] === id));
        console.log(row);
    };

    return (
        <div>
            {(Object.entries(row).map((row) => {
                return (<div className="edit-users-label-bottom">
                    {row[0]}:
                    <FormControl
                        componentClass={'textarea'}
                        className={'form'}
                        id={'edit-name-input'}
                        rows={1}
                        value={row[1] as string || ''}
                        onChange={onChange}
                    />
                </div>);

            }))}
        </div>
    );
});