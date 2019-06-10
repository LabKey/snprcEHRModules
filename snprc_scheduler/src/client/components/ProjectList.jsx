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
import {
    selectProject,
    filterProjects,
    sortProjects,
    createAction,
    PROJECT_SELECTED,
    selectTimeline, TAB_TIMELINES, TAB_PROJECTS, setForceRerender
} from '../actions/dataActions';
import connect from "react-redux/es/connect/connect";
import {BootstrapTable, TableHeaderColumn} from "react-bootstrap-table";

const verboseOutput = true;

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

    handleProjectSearchChange = (event) => this.props.store.dispatch(filterProjects(event.target.value));

    handleStoreUpdate = () => {
        // get all projects from redux
        let projects = this.props.store.getState().project.projects || [];
        // manage project list in local state for rendering
        this.setState({ projects: projects, projectCount: projects.length });
    }

    options = {
        noDataText: 'No projects available',
        defaultSortName: 'description',
        defaultSortOrder: 'asc',
    };

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

    render = () => {
        const { selectedProject } = this.props;

        return (<div>
            <div className="input-group top-bottom-padding-8">
                <span className="input-group-addon input-group-addon-buffer"><Glyphicon glyph="search"/></span>
                <input
                        id="projectSearch"
                        type="text"
                        onChange={this.handleProjectSearchChange}
                        className="form-control search-input"
                        name="projectSearch"
                        placeholder="Search projects"/>
            </div>
            <div className="top-bottom-padding-8 scheduler-project-list">
                <BootstrapTable
                        ref='project-table'
                        className='project-table'
                        data={this.state.projects}
                        options={this.options}
                        selectRow={this.getInnerRowProps(selectedProject ? selectedProject.projectId : -1)}
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
    selectedProject: state.project.selectedProject,
    forceRerender: state.root.forceRerender  // Bit of a hack to get a re-render
})

const mapDispatchToProps = dispatch => ({
    setForceRerender: render => dispatch(setForceRerender(render)),
    onSelectProject: selectedProject => dispatch(selectProject(selectedProject)),
    onSelectTimeline: timeline => dispatch(selectTimeline(timeline))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(ProjectList)