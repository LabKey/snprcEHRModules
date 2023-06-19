import React, { FC, memo } from 'react';
import { connect } from 'react-redux';

import { AppState } from '../reducers';

interface Props {
    selectedProject?: any;
    selectedTimeline?: any;
}

const AnimalDetailsImpl: FC<Props> = memo(({ selectedProject, selectedTimeline }) => {
    return (
        <div
            className="details-frame"
            style={{ textAlign: "center", backgroundColor: "#eee", padding: "10px", marginRight: '30px', marginLeft: '30px' }}
        >
            <h3>{(!selectedProject || !selectedProject.description) ? "Select a Project" : "Project: " + selectedProject.description}</h3>
            <h3>{(!selectedTimeline || !selectedTimeline.Description) ? "Select a Timeline" : "Timeline: " + selectedTimeline.Description}</h3>
        </div>
    );
});

const mapStateToProps = (state: AppState) => ({
    selectedProject: state.project.selectedProject,
    selectedTimeline: state.timeline.selectedTimeline,
})

export default connect(mapStateToProps)(AnimalDetailsImpl);
