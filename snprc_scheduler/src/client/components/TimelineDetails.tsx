import React from 'react';
import {
    setTimelineDayZero,
    updateSelectedTimeline
} from "../actions/dataActions";
import { connect } from "react-redux";
import { Form, FormControl } from "react-bootstrap";
import { Project, Timeline } from "../models/models";

interface TimelineDetailsProps {
    selectedProject: Project | null;
    selectedTimeline: Timeline | null;
    onUpdateSelectedTimeline: (timeline: Partial<Timeline>, dirty: boolean) => void;
    onUpdateTimelineDayZero: (day0: string, forceReload: boolean, dirty: boolean) => void;
}

interface RootState {
    project: {
        selectedProject: Project | null;
    };
    timeline: {
        selectedTimeline: Timeline | null;
    };
}

const TimelineDetails: React.FC<TimelineDetailsProps> = ({ 
    selectedProject, 
    selectedTimeline, 
    onUpdateSelectedTimeline, 
    onUpdateTimelineDayZero 
}) => {
    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        onUpdateSelectedTimeline({
            [e.target.id]: e.target.value,
            IsDirty: true
        }, true)
    };

    const handleDraftCheck = (e: React.ChangeEvent<HTMLInputElement>) => {
        onUpdateSelectedTimeline({
            [e.target.id]: e.target.checked === true ? "In Progress" : "Completed",
            IsDirty: true
        }, true)
    };

    const handleStudyDay0 = (e: React.ChangeEvent<HTMLInputElement>) => {
        const date = e.target.value;
        onUpdateTimelineDayZero(date, true, true);
    };

    const timeline = selectedTimeline || {};

    return (
        <div className='container-fluid details-frame' style={{textAlign: 'left'}}>
            <div className='col-sm-4 zero-right-padding'>
                <div className='row input-row'>
                    <div className='col-sm-4 zero-side-padding'><Form.Label column={true}>Project</Form.Label></div>
                    <div className='col-sm-7'><FormControl type='text' className='input-wide' disabled
                                                     value={selectedProject ? selectedProject.description : ''}
                    /></div>
                </div>
                <div className='row input-row'>
                    <div className='col-sm-4 zero-side-padding'><Form.Label column={true}>Research Coordinator</Form.Label></div>
                    <div className='col-sm-7'><FormControl type='text' className='input-wide' id='RC'
                                    value={timeline.RC ? timeline.RC : ''}
                                    onChange={handleChange}
                                    disabled={!timeline.RowId || timeline.IsInUse}
                    /></div>
                </div>
                <div className='row input-row'>
                    <div className='col-sm-4 zero-side-padding'><Form.Label column={true}>Lead Technician</Form.Label></div>
                    <div className='col-sm-7'><FormControl type='text' className='input-wide' id='LeadTech'
                                    value={timeline.LeadTech ? timeline.LeadTech : ''}
                                    onChange={handleChange}
                                    disabled={!timeline.RowId || timeline.IsInUse}
                    /></div>
                </div>
                <div className='row input-row'>
                    <div className='col-sm-4 zero-side-padding'><Form.Label column={true}>Animal Account</Form.Label></div>
                    <div className='col-sm-7'><FormControl type='text' className='input-wide' id='AnimalAccount'
                                                           value={timeline.AnimalAccount ? timeline.AnimalAccount : ''}
                                                           onChange={handleChange}
                                                           disabled={!timeline.RowId || timeline.IsInUse}
                    /></div>
                </div>
            </div>
            <div className='col-sm-5 zero-left-padding'>
                <div className='row input-row'>
                    <div className='col-sm-6 zero-side-padding'>
                        <div className='col-sm-5 zero-side-padding'><Form.Label column={true}>Created</Form.Label></div>
                        <div className='col-sm-7 zero-side-padding'><FormControl type='date' className='input-wide' id='Created'
                                                         readOnly={true}
                                    value={timeline.Created ? timeline.Created : ''}
                        /></div>
                    </div>
                    <div className='col-sm-6 zero-side-padding'>
                        <div className='col-sm-5 zero-side-padding'><Form.Label column={true}>Created By</Form.Label></div>
                        <div className='col-sm-7 zero-side-padding'><FormControl type='text' className='input-wide' id='CreatedByName'
                                                         readOnly={true}
                                    value={timeline.CreatedByName ? timeline.CreatedByName : ''}
                        /></div>
                    </div>
                </div>
                <div className='row input-row'>
                    <div className='col-sm-6 zero-side-padding'>
                        <div className='col-sm-5 zero-side-padding'><Form.Label column={true}>Modified</Form.Label></div>
                        <div className='col-sm-7 zero-side-padding'><FormControl type='date' className='input-wide' id='Modified'
                                                         readOnly={true}
                                    value={timeline.Modified ? timeline.Modified : ''}
                        /></div>
                    </div>
                    <div className='col-sm-6 zero-side-padding'>
                        <div className='col-sm-5 zero-side-padding'><Form.Label column={true}>Modified By</Form.Label></div>
                        <div className='col-sm-7 zero-side-padding'><FormControl type='text' className='input-wide' id='ModifiedByName'
                                                         readOnly={true}
                                    value={timeline.ModifiedByName ? timeline.ModifiedByName : ''}
                        /></div>
                    </div>
                </div>
                <div className='row input-row'>
                    <div className='col-sm-6 zero-side-padding'>
                        <div className='col-sm-5 zero-side-padding'><Form.Label column={true}>Start</Form.Label></div>
                        <div className='col-sm-7 zero-side-padding'><FormControl type='date' className='input-wide' id='StartDate'
                                                                                 value={timeline.StartDate ? timeline.StartDate : ''}
                                                                                 onChange={handleChange}
                                                                                 disabled={!timeline.RowId  || timeline.IsInUse}
                        /></div>
                    </div>
                    <div className='col-sm-6 zero-side-padding'>
                        <div className='col-sm-5 zero-side-padding'><Form.Label column={true}>End</Form.Label></div>
                        <div className='col-sm-7 zero-side-padding'><FormControl type='date' className='input-wide' id='EndDate'
                                                                                 value={timeline.EndDate ? timeline.EndDate : ''}
                                                                                 onChange={handleChange}
                                                                                 disabled={!timeline.RowId || timeline.IsInUse}
                        /></div>
                    </div>
                </div>
                <div className='row input-row'>
                    <div className='col-sm-6 zero-side-padding'>
                        <div className='col-sm-5 zero-side-padding'><Form.Label column={true}>Study Day 0</Form.Label></div>
                        <div className='col-sm-7 zero-side-padding'><FormControl type='date' className='input-wide' id='StudyDay0'
                                                                                 onChange={handleStudyDay0}
                                                                                 value={timeline.StudyDay0 ? timeline.StudyDay0 : ''}
                                                                                 disabled={!timeline.RowId}
                        /></div>
                    </div>
                    <div className='col-sm-6 zero-side-padding'>
                        <div className='col-sm-5  zero-side-padding'><Form.Label column={true}>Draft</Form.Label></div>
                        <div className='col-sm-7 zero-side-padding margin-small-top'><input type='checkbox' id='QcStateLabel' style={{width: '20px', height: '20px'}}
                                                               checked={timeline.QcStateLabel ? (timeline.QcStateLabel === "In Progress") : false}
                                                               onChange={handleDraftCheck}
                                                               disabled={!timeline.RowId || timeline.IsInUse}
                        /></div>
                    </div>


                </div>
            </div>
            <div className='col-sm-3 zero-right-padding'>
                <div className='row'>
                    <div className='col-sm-4'><Form.Label column={true} className='wrap-words input-wide'>Study Notes</Form.Label></div>
                    <div className='col-sm-7 zero-side-padding'><FormControl as="textarea" id='Notes'
                                    value={timeline.Notes ? timeline.Notes : ''}
                                    onChange={handleChange}
                                    disabled={!timeline.RowId || timeline.IsInUse}
                    /></div>
                </div>
                <div className='row'>
                    <div className='col-sm-4'><Form.Label column={true} className='wrap-words input-wide'>Scheduler Notes</Form.Label></div>
                    <div className='col-sm-7 zero-side-padding'><FormControl as="textarea" id='SchedulerNotes'
                                    value={timeline.SchedulerNotes ? timeline.SchedulerNotes : ''}
                                    onChange={handleChange}
                                    disabled={!timeline.RowId || timeline.IsInUse}
                    /></div>
                </div>
            </div>
        </div>
    )
};

const mapStateToProps = (state: RootState) => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.timeline.selectedTimeline || null
});

const mapDispatchToProps = (dispatch: any) => ({
    onUpdateSelectedTimeline: (timeline: Partial<Timeline>, dirty: boolean) => dispatch(updateSelectedTimeline(timeline, dirty)),
    onUpdateTimelineDayZero: (day0: string, forceReload: boolean, dirty: boolean) => dispatch(setTimelineDayZero(day0, forceReload, dirty))
});

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(TimelineDetails)
