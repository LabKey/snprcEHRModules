import React from 'react';
import PropTypes from "prop-types";
import {selectTimeline, updateSelectedTimeline} from "../actions/dataActions";
import connect from "react-redux/es/connect/connect";
import {Checkbox, ControlLabel, FormControl, FormGroup, HelpBlock} from "react-bootstrap";

const FORCE_RENDER = true;

function FieldGroup({ id, label, help, ...props }) {
    return (
            <FormGroup controlId={id}>
                <ControlLabel>{label}</ControlLabel>
                <FormControl {...props} />
                {help && <HelpBlock>{help}</HelpBlock>}
            </FormGroup>
    );
}

class TimelineDetails extends React.Component {

    constructor(props) {
        super(props);
        this.state = { 
            value: ''
        };
    }

    handleChange = (e) => {
        this.props.onUpdateSelectedTimeline({
            [e.target.id]: e.target.value,
            IsDirty: true
        })
    }

    handleDraftCheck = (e) => {
        this.props.onUpdateSelectedTimeline({
            [e.target.id]: e.target.checked === true ? 4 : 1,
            IsDirty: true
        })
    }

    render() {
        const timeline = this.props.selectedTimeline || {};

        // if (this.props.selectedTimeline != null || FORCE_RENDER) {
            return (
                    <div className='container-fluid details-frame' style={{textAlign: 'left'}}>
                        <div className='col-sm-4'>
                            <div className='row input-row'>
                                <div className='col-sm-4 zero-side-padding'><ControlLabel>Project</ControlLabel></div>
                                <div className='col-sm-7'><FormControl type='text' className='input-wide' disabled
                                                                 value={this.props.selectedProject ? this.props.selectedProject.description : ''}
                                /></div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-4 zero-side-padding'><ControlLabel>Research Coordinator</ControlLabel></div>
                                <div className='col-sm-7'><FormControl type='text' className='input-wide' id='RC'
                                                value={timeline.RC ? timeline.RC : ''}
                                                onChange={this.handleChange}
                                                disabled={!timeline.RowId}
                                /></div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-4 zero-side-padding'><ControlLabel>Lead Technician</ControlLabel></div>
                                <div className='col-sm-7'><FormControl type='text' className='input-wide' id='LeadTech'
                                                value={timeline.LeadTech ? timeline.LeadTech : ''}
                                                onChange={this.handleChange}
                                                disabled={!timeline.RowId}
                                /></div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-4  zero-side-padding'><ControlLabel ref='timeline-draft-state'>Draft</ControlLabel></div>
                                <div className='col-sm-6'><FormControl type='checkbox' id='QcState' style={{width: '20px', height: '20px'}}
                                                checked={timeline.QcState ? (timeline.QcState === 4) : false}
                                                onChange={this.handleDraftCheck}
                                                disabled={!timeline.RowId}
                                /></div>
                            </div>
                        </div>
                        <div className='col-sm-4'>
                            <div className='row input-row'>
                                <div className='col-sm-6 zero-side-padding'>
                                    <div className='col-sm-5 zero-side-padding'><ControlLabel>Start</ControlLabel></div>
                                    <div className='col-sm-7 zero-side-padding'><FormControl type='date' className='input-wide' id='StartDate'
                                                value={timeline.StartDate ? timeline.StartDate : ''}
                                                onChange={this.handleChange}
                                                disabled={!timeline.RowId}
                                    /></div>
                                </div>
                                <div className='col-sm-6 zero-side-padding'>
                                    <div className='col-sm-5 zero-side-padding'><ControlLabel>End</ControlLabel></div>
                                    <div className='col-sm-7 zero-side-padding'><FormControl type='date' className='input-wide' id='EndDate'
                                                value={timeline.EndDate ? timeline.EndDate : ''}
                                                onChange={this.handleChange}
                                                disabled={!timeline.RowId}
                                    /></div>
                                </div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-6 zero-side-padding'>
                                    <div className='col-sm-5 zero-side-padding'><ControlLabel>Created</ControlLabel></div>
                                    <div className='col-sm-7 zero-side-padding'><FormControl type='date' className='input-wide' id='Created'
                                                                     readOnly={true}
                                                value={timeline.Created ? timeline.Created : ''}
                                    /></div>
                                </div>
                                <div className='col-sm-6 zero-side-padding'>
                                    <div className='col-sm-5 zero-side-padding'><ControlLabel>Created By</ControlLabel></div>
                                    <div className='col-sm-7 zero-side-padding'><FormControl type='text' className='input-wide' id='CreatedByName'
                                                                     readOnly={true}
                                                value={timeline.CreatedByName ? timeline.CreatedByName : ''}
                                    /></div>
                                </div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-6 zero-side-padding'>
                                    <div className='col-sm-5 zero-side-padding'><ControlLabel>Modified</ControlLabel></div>
                                    <div className='col-sm-7 zero-side-padding'><FormControl type='date' className='input-wide' id='Modified'
                                                                     readOnly={true}
                                                value={timeline.Modified ? timeline.Modified : ''}
                                    /></div>
                                </div>
                                <div className='col-sm-6 zero-side-padding'>
                                    <div className='col-sm-5 zero-side-padding'><ControlLabel>Modified By</ControlLabel></div>
                                    <div className='col-sm-7 zero-side-padding'><FormControl type='text' className='input-wide' id='ModifiedByName'
                                                                     readOnly={true}
                                                value={timeline.ModifiedByName ? timeline.ModifiedByName : ''}
                                    /></div>
                                </div>
                            </div>

                        </div>
                        <div className='col-sm-4'>
                            <div className='row'>
                                <div className='col-sm-4'><ControlLabel>Study Notes</ControlLabel></div>
                                <div className='col-sm-7 zero-side-padding'><FormControl componentClass="textarea" id='Notes'
                                                value={timeline.Notes ? timeline.Notes : ''}
                                                onChange={this.handleChange}
                                                disabled={!timeline.RowId}
                                /></div>
                            </div>
                            <div className='row'>
                                <div className='col-sm-4'><ControlLabel>Scheduler Notes</ControlLabel></div>
                                <div className='col-sm-7 zero-side-padding'><FormControl componentClass="textarea" id='SchedulerNotes'
                                                value={timeline.SchedulerNotes ? timeline.SchedulerNotes : ''}
                                                onChange={this.handleChange}
                                                disabled={!timeline.RowId}
                                /></div>
                            </div>
                        </div>
                    </div>
            )
        // } else {
        //     return <div>Please select a timeline to view it's details</div>
        // }

    }
}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.timeline.selectedTimeline || null
});

const mapDispatchToProps = dispatch => ({
    onUpdateSelectedTimeline: timeline => dispatch(updateSelectedTimeline(timeline))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(TimelineDetails)