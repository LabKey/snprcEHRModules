/* 
    ==================================================================================
    author:             David P. Smith
    email:              dsmith@txbiomed.org
    name:               snprc_scheduler
    description:        Animal procedure scheduling system     
    copyright:          Texas Biomedical Research Institute
    created:            October 1 2018      
    ==================================================================================
*/
import React from 'react';
import PropTypes from 'prop-types'
import {
    selectProject,
    filterProjects,
    selectTimeline,
    TAB_PROJECTS,
    setForceRerender
} from '../actions/dataActions';
import { connect } from "react-redux";
import { DataGrid } from 'react-data-grid';

class ProjectList extends React.Component {
    
    constructor(props, context) {
        super(props, context);
        this.state = {
            sortColumns: [{ columnKey: 'description', direction: 'ASC' }]
        };
    }

    shouldComponentUpdate(nextProps, nextState, nextContext) {
        const { accordion } = this.props;

        return !!(!accordion || accordion.tab === TAB_PROJECTS);
    }

    onCellClick = (cell) => {
        // Select project and empty selected timeline
        this.props.onSelectProject(cell.row);
        this.props.onSelectTimeline();
    }

    handleProjectSearchChange = (event) => this.props.filterProjects(event.target.value);

    componentDidUpdate() {
        const { forceRerender, setForceRerender } = this.props;
        if( forceRerender ) {
            setForceRerender(false);
        }
    }

    columns = [
        { key: 'Iacuc', name: 'IACUC', width: 80, sortable: true },
        { key: 'description', name: 'Description', sortable: true },
        { key: 'revisionNum', name: 'Rev', width: 40, sortable: true }
    ];

    handleSort = (sortColumns) => {
        this.setState({ sortColumns });
    };

    getSortedRows = () => {
        const { projects } = this.props;
        const { sortColumns } = this.state;

        if (sortColumns.length === 0) return projects;

        const sortColumn = sortColumns[0];
        let sortedRows = [];
        if (projects) {
            sortedRows = [...projects].sort((a, b) => {
                const aVal = a[sortColumn.columnKey];
                const bVal = b[sortColumn.columnKey];

                if (aVal == null && bVal == null) return 0;
                if (aVal == null) return 1;
                if (bVal == null) return -1;

                const comparison = aVal < bVal ? -1 : aVal > bVal ? 1 : 0;
                return sortColumn.direction === 'ASC' ? comparison : -comparison;
            });
        }

        return sortedRows;
    };

    rowClass = (row) => {
        const { selectedProject } = this.props;
        return selectedProject && selectedProject.projectId === row.projectId ? 'rdg-row-selected' : '';
    };

    render = () => {
        const { selectedProject } = this.props;
        const { sortColumns } = this.state;
        const sortedRows = this.getSortedRows();

        return (<div>
            <div className="input-group top-bottom-padding-8">
                <span className="input-group-addon input-group-addon-buffer"><i className="fa fa-search"></i></span>
                <input
                        id="projectSearch"
                        type="text"
                        onChange={this.handleProjectSearchChange}
                        className="form-control search-input"
                        name="projectSearch"
                        placeholder="Search projects"/>
            </div>
            <div className="top-bottom-padding-8 scheduler-project-list">
                <DataGrid
                    key={ selectedProject?.projectId ? 'project-list-' + selectedProject.projectId : 'project-list-none' }
                    className='project-table'
                    columns={this.columns}
                    rows={sortedRows}
                    rowKeyGetter={(row) => row.projectId}
                    onCellClick={this.onCellClick}
                    sortColumns={sortColumns}
                    onSortColumnsChange={this.handleSort}
                    rowClass={this.rowClass}
                    style={{ height: 'calc(48vh - 160px - 50px)' }}
                    defaultColumnOptions={{ resizable: true }}
                />
            </div>
        </div>)
    };

}

const mapStateToProps = state => ({
    projects: state.project.projects,
    selectedProject: state.project.selectedProject,
    forceRerender: state.root.forceRerender  // Bit of a hack to get a re-render
})

const mapDispatchToProps = dispatch => ({
    setForceRerender: render => dispatch(setForceRerender(render)),
    onSelectProject: selectedProject => dispatch(selectProject(selectedProject)),
    onSelectTimeline: timeline => dispatch(selectTimeline(timeline)),
    filterProjects: search => dispatch(filterProjects(search))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(ProjectList)