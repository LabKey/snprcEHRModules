/* 
    ==================================================================================
    author:             David P. Smith
    email:              dsmith@txbiomed.org
    name:               snprc_scheduler
    description:        Animal procedure scheduling system     
    copyright:          Texas Biomedical Research Institute
    created:            October 15 2018      
    ==================================================================================
*/
import React from 'react';
import ReactDataGrid from 'react-data-grid';
import Glyphicon from 'react-bootstrap/lib/Glyphicon'
import {selectTimeline, duplicateTimeline, selectProject} from '../actions/dataActions';
import PropTypes from "prop-types";
import connect from "react-redux/es/connect/connect";

const verboseOutput = false;

class TimelineList extends React.Component {
    
    constructor(props) {
        super(props);
        this.state = {
            debugUI: false,
            timelineCols: [
                { key: 'Description', name: 'Description', width: 373, editable: true }
            ],
            selectedTimelines: [],
            selectedTimeline: (this.props.selectedTimeline || null)
        };
    }

    handleTimelineCreate = () => {
        console.log('handleTimelineCreate()');
    }

    // handleTimelineDuplicate = () => {
    //     this.props.store.dispatch(duplicateTimeline(this.state.selectedTimeline));
    // }

    handleTimelineDestroy = () => {
        console.log('handleTimelineDestroy()');
    }

    timelineRowGetter = (index) =>  {
        if (index > -1)
         return this.props.timelines[index];
    }
    
    onTimelineRowsSelected = (rows) => {
        if (rows.length > 1) {
            rows = [];
        }
        let selectedTimeline = rows.length > 0 ? rows[0].row : null;
        this.setState({
            selectedTimelines: rows.map(r => r.rowIdx) ,
            selectedTimeline: selectedTimeline
        });
        if (selectedTimeline != null) {
            this.props.onSelectTimeline(selectedTimeline);
        }
        if (verboseOutput) {
            console.log(selectedTimeline);
        }
    }

    onTimelineRowsDeselected = (rows) => {
        let rowIndexes = rows.map(r => r.rowIdx);
        this.setState({ selectedTimelines: this.state.selectedTimelines.filter(i => rowIndexes.indexOf(i) === -1) });
    }

    onTimelineRowsUpdated = ({ fromRow, toRow, updated }) => {

    } 

    render = () => { 
        let projectCount = this.props.timelines ? this.props.timelines.length : 0;
        return <div>
        <div className="input-group bottom-padding-8">
            <button title="Create new timeline" className="smooth-border" onClick={this.handleTimelineCreate}><Glyphicon glyph="plus"/></button>
            <button title="Clone selected timeline" className="input-group-left-margin smooth-border" onClick={this.handleTimelineDuplicate}><Glyphicon glyph="copy"/></button>
            <button title="Remove selected timeline" className="input-group-left-margin smooth-border" onClick={this.handleTimelineDestroy}><Glyphicon glyph="trash"/></button>
        </div>
        <div>
            <ReactDataGrid
                rowKey="id3"
                enableCellSelect={true}
                columns={this.state.timelineCols}
                rowGetter={this.timelineRowGetter}
                rowsCount={projectCount}
                minHeight={300}
                onGridRowsUpdated={this.onTimelineRowsUpdated}
                rowSelection={{
                    showCheckbox: true,
                    enableShiftSelect: true,
                    onRowsSelected: this.onTimelineRowsSelected,
                    onRowsDeselected: this.onTimelineRowsDeselected,
                    selectBy: { indexes: this.state.selectedTimelines }
                }} />                                    
        </div>
    </div>
    }

  }

TimelineList.propTypes = {
    onSelectTimeline: PropTypes.func.isRequired
}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: (state.project.selectedProject != null) ? state.project.selectedProject.selectedTimeline : null,
    timelines: state.project.timelines  || null
})

const mapDispatchToProps = dispatch => ({
    onSelectTimeline: selectedTimeline => dispatch(selectTimeline(selectedTimeline))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(TimelineList)