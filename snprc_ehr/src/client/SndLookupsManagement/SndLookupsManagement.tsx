import React, { FC, useState } from 'react';
import './styles/sndLookupsManagement.scss'

import {
    Alert,
    InjectedQueryModels,
    withQueryModels
} from '@labkey/components';
import { Col, Row } from 'react-bootstrap';
import { TableGridPanel } from './components/TableGridPanel';
import { SCHEMAS } from './schemas';
import { Filter } from '@labkey/api';

export const SndLookupsManagementImpl: FC<InjectedQueryModels> = React.memo(props => {
    const [lookupSetId, setLookupSetId] = useState<string>('');
    const [row, setRow] = useState<any>(undefined);
    const [message, setMessage] = useState<string>('');
    const [error, setError] = useState<string>('');
    const { actions, queryModels } = props;

    const handleSelectedParentRow = async (id: string, row: any) => {
        setLookupSetId(id);
        setRow(row);
    }

    const onSuccess = (response: any) => {
        let responseMsg: string;
        if (response.command == "insert") response.command = "create";
        responseMsg = "Successfully " + response.command + "d " + response.queryName.slice(0, -1) + " \'"
            + (response.rows[0]['setName'] ?? response.rows[0]['value']) + "\'!";
        setMessage(responseMsg);
        if (response['htmlErrors']?.length > 0) {
            setError(response['htmlErrors'].join(' '));
        }
        window.setTimeout(() => setMessage(undefined), 60000);
    }

    return (
        <div>
            <Alert bsStyle="success">{message}</Alert>
            <Alert>{error}</Alert>
            <Row>
                <Col xs={10} md={4} className={"sidenav"} >
                    <TableGridPanel table={"LookupSets"}
                                    rowIdName={"LookupSetId"}
                                    rowNameField={"SetName"}
                                    actions={actions}
                                    omittedColumns={['label', 'description', 'container', 'createdby', 'created', 'modifiedby', 'modified', 'objectid']}
                                    queryModels={queryModels}
                                    schemaQuery={SCHEMAS.SND_TABLES.LOOKUP_SETS}
                                    title={"Lookup Set"}
                                    handleSelectedParentRow={handleSelectedParentRow}
                                    onChange={onSuccess}
                                    filters={[]}/>
                </Col>
                <Col xs={10} md={7}>
                    {lookupSetId && (

                    <TableGridPanel table={"Lookups"}
                                    rowIdName={"LookupId"}
                                    rowNameField={"Value"}
                                    actions={actions}
                                    omittedColumns={['label', 'description', 'container', 'createdby', 'created', 'modifiedby', 'modified', 'objectid', 'sortOrder']}
                                    queryModels={queryModels}
                                    schemaQuery={SCHEMAS.SND_TABLES.LOOKUPS}
                                    title={"Lookup"}
                                    parentId={lookupSetId}
                                    parentIdName={"LookupSetId"}
                                    parentName={row["SetName"]}
                                    onChange={onSuccess}
                                    filters={[Filter.create('lookupSetId', lookupSetId)] }
                                     />
                    )}
                </Col>
            </Row>
        </div>
    );
});

export const SndLookupsManagement = withQueryModels<{}>(SndLookupsManagementImpl);

