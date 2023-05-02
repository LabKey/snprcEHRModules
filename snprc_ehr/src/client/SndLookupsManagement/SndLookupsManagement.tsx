import React, { FC, useState } from 'react';
import './styles/sndLookupsManagement.scss'

import {
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
    const { actions, queryModels } = props;

    const handleSelectedParentRow = async (id: string, row: any) => {
        setLookupSetId(id);
        setRow(row);
    }

    const onSuccess = (response: any) => {

    }

    return (

        <div>
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
                                    onCreate={onSuccess}
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
                                    onCreate={onSuccess}
                                    filters={[Filter.create('lookupSetId', lookupSetId)] }
                                     />
                    )}
                </Col>
            </Row>
        </div>
    );
});

export const SndLookupsManagement = withQueryModels<{}>(SndLookupsManagementImpl);

