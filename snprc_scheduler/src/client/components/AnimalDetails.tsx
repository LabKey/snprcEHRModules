import React, { FC } from 'react';
import { connect } from 'react-redux';
import { Project, Timeline } from '../models/models';

interface AnimalDetailsProps {
    selectedProject: null | Project;
    selectedTimeline: null | Timeline;
}

interface RootState {
    project: {
        selectedProject: null | Project;
    };
    timeline: {
        selectedTimeline: null | Timeline;
    };
}

const AnimalDetails: FC<AnimalDetailsProps> = ({ selectedProject, selectedTimeline }) => {
    return (
        <div
            className={'details-frame'}
            style={{
                textAlign: 'center',
                backgroundColor: '#eee',
                padding: '10px',
                marginRight: '30px',
                marginLeft: '30px',
            }}
        >
            <h3>
                {!selectedProject || !selectedProject.description
                    ? 'Select a Project'
                    : 'Project: ' + selectedProject.description}
            </h3>
            <h3>
                {!selectedTimeline || !selectedTimeline.Description
                    ? 'Select a Timeline'
                    : 'Timeline: ' + selectedTimeline.Description}
            </h3>
        </div>
    );
};

const mapStateToProps = (state: RootState): AnimalDetailsProps => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.timeline.selectedTimeline || null,
});

export default connect(mapStateToProps)(AnimalDetails);
