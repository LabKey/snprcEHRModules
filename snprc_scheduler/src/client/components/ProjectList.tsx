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
import { Glyphicon } from 'react-bootstrap';
import { connect } from 'react-redux';
import { BootstrapTable, TableHeaderColumn } from 'react-bootstrap-table';

import { AppState } from '../reducers';
import {
    selectProject,
    filterProjects,
    selectTimeline,
    setForceRerender,
    TAB_PROJECTS,
} from '../actions/dataActions';

class ProjectList extends React.Component<any> {
    
    shouldComponentUpdate(nextProps, nextState, nextContext): boolean {
        const { accordion } = this.props;

        return !!(!accordion || accordion.tab === TAB_PROJECTS);
    }

    onProjectRowsSelected = (row, isSelected, e) => {

        // Select project and empty selected timeline
        if (isSelected) {
            this.props.onSelectProject(row);
            this.props.onSelectTimeline();
            return true;
        }

        // Cannot unselect
        return false;
    }

    handleProjectSearchChange = (event) => this.props.filterProjects(event.target.value);

    getInnerRowProps = (project) => {
        return {
            mode: 'radio',
            clickToSelect: true,
            onSelect: this.onProjectRowsSelected,
            selected: (project >= 0 ? [project] : [])
        }
    };

    componentDidUpdate() {
        const { forceRerender, setForceRerender } = this.props;
        if( forceRerender ) {
            setForceRerender(false);
        }
    }

    options = {
        noDataText: 'No projects available',
        defaultSortName: 'description',
        defaultSortOrder: 'asc',
    };

    render = () => {
        const { selectedProject, projects } = this.props;

        return (
            <div>
                <div className="input-group top-bottom-padding-8">
                    <span className="input-group-addon input-group-addon-buffer"><Glyphicon glyph="search"/></span>
                    <input
                        id="projectSearch"
                        type="text"
                        onChange={this.handleProjectSearchChange}
                        className="form-control search-input"
                        name="projectSearch"
                        placeholder="Search projects"
                    />
                </div>
                <div className="top-bottom-padding-8 scheduler-project-list">
                    <BootstrapTable
                        ref='project-table'
                        className='project-table'
                        data={projects}
                        options={this.options}
                        selectRow={this.getInnerRowProps(selectedProject ? selectedProject.projectId : -1)}
                        height={224}
                    >
                        <TableHeaderColumn dataField="projectId" isKey hidden />
                        <TableHeaderColumn dataField="Iacuc" width="80px" dataSort>IACUC</TableHeaderColumn>
                        <TableHeaderColumn dataField="description" dataSort>Description</TableHeaderColumn>
                        <TableHeaderColumn dataField="revisionNum" width="40px">Rev</TableHeaderColumn>
                    </BootstrapTable>
                </div>
            </div>
        );
    };
}

const mapStateToProps = (state: AppState) => ({
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

export default connect(mapStateToProps, mapDispatchToProps)(ProjectList);
