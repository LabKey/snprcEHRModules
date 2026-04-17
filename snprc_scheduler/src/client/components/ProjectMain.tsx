import React, { FC } from 'react';
import { connect } from 'react-redux';
import { Column, DataGrid } from 'react-data-grid';
import { Project } from '../models/models';

interface ProjectMainProps {
    projects: null | Project[];
    selectedProject: null | Project;
}

interface RootState {
    project: {
        projects: null | Project[];
        selectedProject: null | Project;
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
    { key: 'endDate', name: 'End Date', sortable: true },
];

const ProjectMain: FC<ProjectMainProps> = ({ projects }) => {
    const rows = projects || [];

    return (
        <div className="col-sm-12 scheduler-main-table">
            <h4>All Active Projects</h4>
            <DataGrid
                className="project-main-table rdg-light"
                columns={columns}
                defaultColumnOptions={{ resizable: true, sortable: true }}
                rowKeyGetter={row => row.projectId}
                rows={rows}
                style={{ height: 'calc(67vh - 160px - 50px)' }}
            />
        </div>
    );
};

const mapStateToProps = (state: RootState): ProjectMainProps => ({
    selectedProject: state.project.selectedProject || null,
    projects: state.project.projects || null,
});

export default connect(mapStateToProps)(ProjectMain);
