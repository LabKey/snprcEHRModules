import React from "react";
import connect from "react-redux/es/connect/connect";


class AnimalMain extends React.Component {

    render() {
        return <div
                style={{ textAlign: "center", backgroundColor: "#eee", padding: "100px", height: "465px" }}
        >
            <h3>{(!this.props.selectedProject || !this.props.selectedProject.description) ? "Select a Project" : "Project: " + this.props.selectedProject.description}</h3>
            <h3>{(!this.props.selectedTimeline || !this.props.selectedTimeline.Description) ? "Select a Timeline" : "Timeline: " + this.props.selectedTimeline.Description}</h3>
        </div>
    }

}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.timeline.selectedTimeline || null
})

export default connect(
        mapStateToProps
)(AnimalMain)