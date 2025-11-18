import React from "react";
import { connect } from "react-redux";
import { Project, Timeline } from "../models/models";

interface AnimalDetailsProps {
    selectedProject: Project | null;
    selectedTimeline: Timeline | null;
}

interface RootState {
    project: {
        selectedProject: Project | null;
    };
    timeline: {
        selectedTimeline: Timeline | null;
    };
}

const AnimalDetails: React.FC<AnimalDetailsProps> = ({ selectedProject, selectedTimeline }) => {
    return (
        <div className={'details-frame'}
             style={{ textAlign: "center", backgroundColor: "#eee", padding: "10px", marginRight: '30px', marginLeft: '30px' }}
        >
            <h3>{(!selectedProject || !selectedProject.description) ? "Select a Project" : "Project: " + selectedProject.description}</h3>
            <h3>{(!selectedTimeline || !selectedTimeline.Description) ? "Select a Timeline" : "Timeline: " + selectedTimeline.Description}</h3>
        </div>
    );
};

const mapStateToProps = (state: RootState): AnimalDetailsProps => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.timeline.selectedTimeline || null
})

export default connect(
        mapStateToProps
)(AnimalDetails)
