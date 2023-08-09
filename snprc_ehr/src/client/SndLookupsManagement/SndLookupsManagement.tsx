import React, { FC, useState } from 'react';
import './styles/sndLookupsManagement.scss';

import {
    Alert,
} from '@labkey/components';
import { Col, Row } from 'react-bootstrap';
import { TableGridPanel } from './components/TableGridPanel';
import { SCHEMAS } from './schemas';
import { Filter } from '@labkey/api';

export const SndLookupsManagement: FC = React.memo(props => {

    const [lookupSetId, setLookupSetId] = useState<string>('');
    const [lookupSetName, setLookupSetName] = useState<string>('');
    const [message, setMessage] = useState<string>('');
    const [error, setError] = useState<string>('');

    /**
     * Callback for setting state when new row is selected
     * @param id
     * @param row
     */
    const handleSelectedParentRow = (id: string, row: any) => {
        setLookupSetId(id);
        setLookupSetName(row?.SetName);
    };

    /**
     * Callback for displaying a message upon successful database change
     * @param response
     */
    const onSuccess = (response: any) => {
        let responseMsg: string;
        if (response.command == 'insert') {
            response.command = 'create';
        }

        responseMsg = 'Successfully ' + response.command + 'd ' + response.queryName.slice(0, -1) + ' \''
            + (response.rows[0]['setName'] ?? response.rows[0]['value']) + '\'!';
        setMessage(responseMsg);
        if (response['htmlErrors']?.length > 0) {
            setError(response['htmlErrors'].join(' '));
        }
        window.setTimeout(() => setMessage(undefined), 60000);
    };

    return (
        <div>
            <Row>
                <Col xs={10} md={12} lg={11}>
                    <Alert className={'success-alert'} bsStyle="success">{message}</Alert>
                    <Alert>{error}</Alert>
                </Col>
            </Row>

            <Row className={'snd-lookups-grid'}>
                <Col xs={10} md={5} lg={4} className={'lookupSets-grid'} data-testid={'lookup-sets'}>
                    <TableGridPanel table={'LookupSets'}
                                    rowIdName={'LookupSetId'}
                                    rowNameField={'SetName'}
                                    omittedColumns={['label', 'description', 'container', 'createdby', 'created', 'modifiedby', 'modified', 'objectid']}
                                    displayColumns={['lookupSetId', 'description', 'label', 'setName', 'isInUse']}
                                    schemaQuery={SCHEMAS.SND_TABLES.LOOKUP_SETS}
                                    title={'Lookup Set'}
                                    handleSelectedParentRow={handleSelectedParentRow}
                                    onChange={onSuccess}
                                    filters={[]}/>
                </Col>
                <Col xs={10} md={7} lg={7} className={'lookups-grid'} data-testid={'lookups'}>
                    {lookupSetId && (

                        <TableGridPanel table={'Lookups'}
                                        rowIdName={'LookupId'}
                                        rowNameField={'Value'}
                                        omittedColumns={['label', 'description', 'container', 'createdby', 'created', 'modifiedby', 'modified', 'objectid']}
                                        displayColumns={['lookupId', 'LookupSetId', 'value', 'displayable', 'sortOrder', 'isInUse']}
                                        schemaQuery={SCHEMAS.SND_TABLES.LOOKUPS}
                                        title={'Lookup'}
                                        parentId={lookupSetId}
                                        parentIdName={'LookupSetId'}
                                        parentName={lookupSetName}
                                        onChange={onSuccess}
                                        filters={[Filter.create('lookupSetId', lookupSetId)]}
                        />
                    ) || (
                        <h3 className="lookups-placeholder">Select a Lookup Set ☑ to display Lookups</h3>
                    )
                    }
                </Col>
            </Row>
        </div>
    );
});

export default SndLookupsManagement;