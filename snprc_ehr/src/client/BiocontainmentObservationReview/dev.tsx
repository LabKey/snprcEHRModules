import React from 'react';
import ReactDOM from 'react-dom';

import BiocontainmentObservationReview from './BiocontainmentObservationReview';

const render = () => {
    // eslint-disable-next-line react/no-deprecated -- this module is on React 16, which has no createRoot
    ReactDOM.render(<BiocontainmentObservationReview />, document.getElementById('app'));
};

render();
