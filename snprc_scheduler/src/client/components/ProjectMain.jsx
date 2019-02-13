import React from "react";
import connect from "react-redux/es/connect/connect";
import {BootstrapTable, TableHeaderColumn} from "react-bootstrap-table";


class ProjectMain extends React.Component {

    selectedOptions = {
        noDataText: 'No selected project data'
    };

    options = {
        noDataText: 'No project data'
    };

    render() {

        let selectedProjects = [];
        if (this.props.selectedProject && this.props.selectedProject.projectId) {
            selectedProjects = [this.props.selectedProject];
        } else {
            selectedProjects = [];
        }

        return <div>

            <div><h4>All Active Projects</h4></div>
            <BootstrapTable
                    ref='project-main-table'
                    className='project-main-table'
                    data={this.props.projects}
                    options={this.options}
                    height={445}
            >
                <TableHeaderColumn dataField='projectId' isKey={true}>Project ID</TableHeaderColumn>
                <TableHeaderColumn dataField='revisionNum'>Revision</TableHeaderColumn>
                <TableHeaderColumn dataField='description' width='200px'>Description</TableHeaderColumn>
                <TableHeaderColumn dataField='Iacuc'>IACUC</TableHeaderColumn>
                <TableHeaderColumn dataField='CostAccount'>Cost Account</TableHeaderColumn>
                <TableHeaderColumn dataField='Veterinarian1'>Veterinarian 1</TableHeaderColumn>
                <TableHeaderColumn dataField='Veterinarian2'>Veterinarian 2</TableHeaderColumn>
                <TableHeaderColumn dataField='VsNumber'>VsNumber</TableHeaderColumn>
                <TableHeaderColumn dataField='referenceId'>Reference ID</TableHeaderColumn>
                <TableHeaderColumn dataField='FeeScheduler'>Fee Schedule</TableHeaderColumn>
                <TableHeaderColumn dataField='startDate'>Start Date</TableHeaderColumn>
                <TableHeaderColumn dataField='endDate'>End Date</TableHeaderColumn>

            </BootstrapTable>
        </div>
    }

}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null,
    projects: state.project.projects || null
})

export default connect(
        mapStateToProps
)(ProjectMain)