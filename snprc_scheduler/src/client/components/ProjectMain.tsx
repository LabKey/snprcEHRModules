import React from "react";
import { connect } from "react-redux";
import { DataGrid, Column } from "react-data-grid";
import { Project } from "../models/models";

interface ProjectMainProps {
    selectedProject: Project | null;
    projects: Project[] | null;
}

interface RootState {
    project: {
        selectedProject: Project | null;
        projects: Project[] | null;
    };
}

const columns: Column<Project>[] = [
    { key: 'projectId', name: 'Project ID', sortable: true },
    { key: 'revisionNum', name: 'Revision', sortable: true },
    { key: 'description', name: 'Description', width: 200, sortable: true },
    { key: 'Iacuc', name: 'IACUC', sortable: true },
    { key: 'CostAccount', name: 'Cost Account', sortable: true },
    { key: 'Veterinarian1', name: 'Vet 1', sortable: true },
    { key: 'Veterinarian2', name: 'Vet 2', sortable: true },
    { key: 'VsNumber', name: 'VsNumber', sortable: true },
    { key: 'referenceId', name: 'Reference ID', sortable: true },
    { key: 'FeeScheduler', name: 'Fee Schedule', sortable: true },
    { key: 'startDate', name: 'Start Date', sortable: true },
    { key: 'endDate', name: 'End Date', sortable: true }
];

const ProjectMain: React.FC<ProjectMainProps> = ({ projects }) => {
    const rows = projects || [];

    return (
        <div className='col-sm-12 scheduler-main-table'>
            <h4>All Active Projects</h4>
            <DataGrid
                className='project-main-table rdg-light'
                columns={columns}
                rows={rows}
                rowKeyGetter={(row) => row.projectId}
                style={{ height: 'calc(67vh - 160px - 50px)' }}
                defaultColumnOptions={{ resizable: true, sortable: true }}
            />
        </div>
    );
}

const mapStateToProps = (state: RootState): ProjectMainProps => ({
    selectedProject: state.project.selectedProject || null,
    projects: state.project.projects || null
})

export default connect(
        mapStateToProps
)(ProjectMain)
