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
    const { actions, queryModels } = props;

    const handleSelectedParentRow = (id: string): void => {
        setLookupSetId(id);
    }

    const onSuccess = (response: any) => {

    }

    return (

        <div>
            <Row>
                <Col xs={10} md={4} className={"sidenav"} >
                    <TableGridPanel table={"LookupSets"}
                                    rowIdName={"LookupSetId"}
                                    actions={actions}
                                    omittedColumns={['label', 'description', 'Folder', 'createdby', 'created', 'modifiedby', 'modified', 'objectid']}
                                    queryModels={queryModels}
                                    schemaQuery={SCHEMAS.SND_TABLES.LOOKUP_SETS}
                                    title={"Lookup Key"}
                                    handleSelectedParentRow={handleSelectedParentRow}
                                    onChange={onSuccess}
                                    onCreate={onSuccess}
                                    filters={[]}/>
                </Col>
                <Col xs={10} md={7}>
                    {lookupSetId && (

                    <TableGridPanel table={"Lookups"}
                                    rowIdName={"LookupId"}
                                    actions={actions}
                                    omittedColumns={['label', 'description', 'folder', 'createdby', 'created', 'modifiedby', 'modified', 'objectid', 'sortOrder']}
                                    queryModels={queryModels}
                                    schemaQuery={SCHEMAS.SND_TABLES.LOOKUPS}
                                    title={"Lookup Value"}
                                    parentId={lookupSetId}
                                    parentIdName={"LookupSetId"}
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