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
import ReactDataGrid from 'react-data-grid';
import Glyphicon from 'react-bootstrap/lib/Glyphicon'
import {selectProject, filterProjects, sortProjects, createAction, PROJECT_SELECTED} from '../actions/dataActions';
import connect from "react-redux/es/connect/connect";
import {BootstrapTable, TableHeaderColumn} from "react-bootstrap-table";

const verboseOutput = true;

class EmptyProjectRowsView extends React.Component { render() {return (<div> Loading active projects...</div>);} }

class ProjectList extends React.Component {
    
    constructor(props, context) {
        super(props, context);
        this.state = {
            projectCols: [
                { key: 'Iacuc', name: 'IACUC', width: 75, sortable: true },
                { key: 'description', name: 'Description', width: 255, sortable: true },
                { key: 'revisionNum', name: 'Rev', width: 42, sortable: true }
            ],
            selectedProjects: [],
            sortColumn: null, 
            sortDirection: null,
            filters: {}
        };
        // wire into redux store updates
        this.disconnect = this.props.store.subscribe(this.handleStoreUpdate);
    }

    componentWillUnmount = () => this.disconnect();

    shouldComponentUpdate(nextProps, nextState, nextContext) {
        return true;
    }
    
    onProjectRowsSelected = (row, isSelected, e) => {

        if (isSelected) {
            this.props.onSelectProject(row);
        } else {

        }
    }

    onProjectRowsDeselected = (rows) => {
        let rowIndexes = rows.map(r => r.rowIdx);
        this.setState({ selectedProjects: this.state.selectedProjects.filter(i => rowIndexes.indexOf(i) === -1) });       
    }

    projectRowGetter = (index) => this.state.projects[index];   
    
    handleProjectSearchChange = (event) => this.props.store.dispatch(filterProjects(event.target.value));

    handleStoreUpdate = () => {
        // get all projects from redux
        let projects = this.props.store.getState().project.projects || [];
        // manage project list in local state for rendering
        this.setState({ projects: projects, projectCount: projects.length });
    }

    handleGridSort = (sortColumn, sortDirection) => {
        // de-select any currently selected projects
        this.setState({ selectedProjects: [], selectedProject: null });
        // dispatch our filter request
        this.props.store.dispatch(sortProjects(sortColumn, sortDirection));
    };

    options = {
        noDataText: 'No projects available',
        defaultSortName: 'description',
        defaultSortOrder: 'asc'
    };

    selectRowProp = {
        mode: 'radio',
        clickToSelect: true,
        onSelect: this.onProjectRowsSelected
    };

    render = () => {
        return (<div>
            <div className="input-group bottom-padding-8">
                <span className="input-group-addon input-group-addon-buffer"><Glyphicon glyph="search"/></span>
                <input
                        id="projectSearch"
                        type="text"
                        onChange={this.handleProjectSearchChange}
                        className="form-control search-input"
                        name="projectSearch"
                        placeholder="Search projects"/>
            </div>
            <div className="bottom-padding-8 scheduler-project-list">
                <BootstrapTable
                        ref='project-table'
                        className='project-table'
                        data={this.state.projects}
                        options={this.options}
                        selectRow={this.selectRowProp}
                        height={224}
                >
                    <TableHeaderColumn dataField='projectId' isKey={true} hidden/>
                    <TableHeaderColumn dataField='Iacuc' width='80px' dataSort={ true }>IACUC</TableHeaderColumn>
                    <TableHeaderColumn dataField='description' dataSort={ true }>Description</TableHeaderColumn>
                    <TableHeaderColumn dataField='revisionNum' width='40px'>Rev</TableHeaderColumn>
                </BootstrapTable>
            </div>
        </div>)
    };

}

ProjectList.propTypes = {
    onSelectProject: PropTypes.func.isRequired
}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject
})

const mapDispatchToProps = dispatch => ({
    onSelectProject: selectedProject => dispatch(selectProject(selectedProject))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(ProjectList)