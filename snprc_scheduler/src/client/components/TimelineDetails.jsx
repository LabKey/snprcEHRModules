import React from 'react';
import PropTypes from "prop-types";
import {selectTimeline} from "../actions/dataActions";
import connect from "react-redux/es/connect/connect";

const FORCE_RENDER = true;

class TimelineDetails extends React.Component {

    constructor(props) {
        super(props);
        this.state = { 
            value: ''
        };
    }

    render() {
        if (this.props.selectedTimeline != null || FORCE_RENDER) {
            return (
                    <div className='container-fluid details-frame' style={{textAlign: 'left'}}>
                        <div className='col-sm-4'>
                            <div className='row input-row'>
                                <div className='col-sm-4 zero-side-padding'><label>Project</label></div>
                                <div className='col-sm-7'><input type='text' className='input-wide' disabled
                                                                 value={this.props.selectedProject ? this.props.selectedProject.description : ''}
                                /></div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-4 zero-side-padding'><label>Research Coordinator</label></div>
                                <div className='col-sm-7'><input type='text' className='input-wide'
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.LeadTechs : ''}
                                /></div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-4 zero-side-padding'><label>Lead Technitian</label></div>
                                <div className='col-sm-7'><input type='text' className='input-wide'
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.LeadTechs : ''}
                                /></div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-4  zero-side-padding'><label>Draft</label></div>
                                <div className='col-sm-6'><input type='checkbox'
                                                                 style={{width: '20px', height: '20px'}}
                                                value={this.props.selectedTimeline ? (this.props.selectedTimeline.QcState === 4) : false}
                                /></div>
                            </div>
                        </div>
                        <div className='col-sm-4'>
                            <div className='row input-row'>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><label>Start</label></div>
                                    <div className='col-sm-8'><input type='date' className='input-wide'
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.StartDate : ''}
                                    /></div>
                                </div>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><label>End</label></div>
                                    <div className='col-sm-8'><input type='date' className='input-wide'
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.EndDate : ''}
                                    /></div>
                                </div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><label>Created</label></div>
                                    <div className='col-sm-8'><input type='date' className='input-wide'
                                                                     readOnly={true}
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.Created : ''}
                                    /></div>
                                </div>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><label>Created By</label></div>
                                    <div className='col-sm-8'><input type='text' className='input-wide'
                                                                     readOnly={true}
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.CreatedByName : ''}
                                    /></div>
                                </div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><label>Modified</label></div>
                                    <div className='col-sm-8'><input type='date' className='input-wide'
                                                                     readOnly={true}
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.Modified : ''}
                                    /></div>
                                </div>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><label>Modified By</label></div>
                                    <div className='col-sm-8'><input type='text' className='input-wide'
                                                                     readOnly={true}
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.ModifiedByName : ''}
                                    /></div>
                                </div>
                            </div>

                        </div>
                        <div className='col-sm-4'>
                            <div className='row' style={{marginLeft: '20px'}}>
                                <div className='col-sm-4'><label>Study Notes</label></div>
                                <div className='col-sm-8 zero-side-padding'><textarea rows='3' cols='50'
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.Notes : ''}
                                /></div>
                            </div>
                            <div className='row' style={{marginLeft: '20px'}}>
                                <div className='col-sm-4'><label>Scheduler Notes</label></div>
                                <div className='col-sm-8 zero-side-padding'><textarea rows='3' cols='50'
                                                value={this.props.selectedTimeline ? this.props.selectedTimeline.SchedulerNotes : ''}
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
})

export default connect(
        mapStateToProps
)(TimelineDetails)