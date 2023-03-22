import React, { FC} from 'react';

import { LookupSetsGridPanel } from './components/LookupSetsGridPanel';

export const SndLookupsManagement: FC = React.memo(props => {
    return (
        <div>
            <LookupSetsGridPanel />
        </div>
    );
});