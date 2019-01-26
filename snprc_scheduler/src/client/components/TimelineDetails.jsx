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
        if (this.props.selectedTimeline != null || FORCE_RENDER) {
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
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.RC : ''}
                                                onChange={this.handleChange}
                                /></div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-4 zero-side-padding'><ControlLabel>Lead Technician</ControlLabel></div>
                                <div className='col-sm-7'><FormControl type='text' className='input-wide' id='LeadTechs'
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.LeadTechs : ''}
                                                onChange={this.handleChange}
                                /></div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-4  zero-side-padding'><ControlLabel>Draft</ControlLabel></div>
                                <div className='col-sm-6'><FormControl type='checkbox' id='QcState' style={{width: '20px', height: '20px'}}
                                                checked={this.props.selectedTimeline && this.props.selectedTimeline.QcState ? (this.props.selectedTimeline.QcState === 4) : false}
                                                onChange={this.handleDraftCheck}
                                /></div>
                            </div>
                        </div>
                        <div className='col-sm-4'>
                            <div className='row input-row'>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><ControlLabel>Start</ControlLabel></div>
                                    <div className='col-sm-8'><FormControl type='date' className='input-wide' id='StartDate'
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.StartDate : ''}
                                                onChange={this.handleChange}
                                    /></div>
                                </div>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><ControlLabel>End</ControlLabel></div>
                                    <div className='col-sm-8'><FormControl type='date' className='input-wide' id='EndDate'
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.EndDate : ''}
                                                onChange={this.handleChange}
                                    /></div>
                                </div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><ControlLabel>Created</ControlLabel></div>
                                    <div className='col-sm-8'><FormControl type='date' className='input-wide' id='Created'
                                                                     readOnly={true}
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.Created : ''}
                                    /></div>
                                </div>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><ControlLabel>Created By</ControlLabel></div>
                                    <div className='col-sm-8'><FormControl type='text' className='input-wide' id='CreatedByName'
                                                                     readOnly={true}
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.CreatedByName : ''}
                                    /></div>
                                </div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><ControlLabel>Modified</ControlLabel></div>
                                    <div className='col-sm-8'><FormControl type='date' className='input-wide' id='Modified'
                                                                     readOnly={true}
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.Modified : ''}
                                    /></div>
                                </div>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><ControlLabel>Modified By</ControlLabel></div>
                                    <div className='col-sm-8'><FormControl type='text' className='input-wide' id='ModifiedByName'
                                                                     readOnly={true}
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.ModifiedByName : ''}
                                    /></div>
                                </div>
                            </div>

                        </div>
                        <div className='col-sm-4'>
                            <div className='row' style={{marginLeft: '20px'}}>
                                <div className='col-sm-4'><ControlLabel>Study Notes</ControlLabel></div>
                                <div className='col-sm-8 zero-side-padding'><FormControl componentClass="textarea" id='Notes'
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.Notes : ''}
                                                onChange={this.handleChange}
                                /></div>
                            </div>
                            <div className='row' style={{marginLeft: '20px'}}>
                                <div className='col-sm-4'><ControlLabel>Scheduler Notes</ControlLabel></div>
                                <div className='col-sm-8 zero-side-padding'><FormControl componentClass="textarea" id='SchedulerNotes'
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.SchedulerNotes : ''}
                                                onChange={this.handleChange}
                                /></div>
                            </div>
                        </div>
                    </div>
            )
        } else {
            return <div>Please select a timeline to view it's details</div>
        }

    }
}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.project.selectedTimeline || null
});

const mapDispatchToProps = dispatch => ({
    onUpdateSelectedTimeline: timeline => dispatch(updateSelectedTimeline(timeline))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(TimelineDetails)