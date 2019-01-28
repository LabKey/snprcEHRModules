import React from "react";
import connect from "react-redux/es/connect/connect";


class ProjectMain extends React.Component {

    render() {
        return <div
                style={{ textAlign: "center", backgroundColor: "#eee", padding: "100px", height: "565px" }}
        >
            <h3>{(!this.props.selectedProject || !this.props.selectedProject.description) ? "Select a Project" : "Project: " + this.props.selectedProject.description}</h3>
        </div>
    }

}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null
})

export default connect(
        mapStateToProps
)(ProjectMain)