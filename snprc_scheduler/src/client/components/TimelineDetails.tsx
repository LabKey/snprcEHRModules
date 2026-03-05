import React, { ChangeEvent, FC } from 'react';
import { setTimelineDayZero, updateSelectedTimeline } from '../actions/dataActions';
import { connect } from 'react-redux';
import { Form, FormControl } from 'react-bootstrap';
import { Project, Timeline } from '../models/models';

interface TimelineDetailsProps {
    onUpdateSelectedTimeline: (timeline: Partial<Timeline>, dirty: boolean) => void;
    onUpdateTimelineDayZero: (day0: string, forceReload: boolean, dirty: boolean) => void;
    selectedProject: null | Project;
    selectedTimeline: null | Timeline;
}

interface RootState {
    project: {
        selectedProject: null | Project;
    };
    timeline: {
        selectedTimeline: null | Timeline;
    };
}

const TimelineDetails: FC<TimelineDetailsProps> = ({
    selectedProject,
    selectedTimeline,
    onUpdateSelectedTimeline,
    onUpdateTimelineDayZero,
}) => {
    const handleChange = (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        onUpdateSelectedTimeline(
            {
                [e.target.id]: e.target.value,
                IsDirty: true,
            },
            true
        );
    };

    const handleDraftCheck = (e: ChangeEvent<HTMLInputElement>) => {
        onUpdateSelectedTimeline(
            {
                [e.target.id]: e.target.checked === true ? 'In Progress' : 'Completed',
                IsDirty: true,
            },
            true
        );
    };

    const handleStudyDay0 = (e: ChangeEvent<HTMLInputElement>) => {
        const date = e.target.value;
        onUpdateTimelineDayZero(date, true, true);
    };

    const timeline = selectedTimeline || {};

    return (
        <div className="container-fluid details-frame" style={{ textAlign: 'left' }}>
            <div className="col-sm-4 zero-right-padding">
                <div className="row input-row">
                    <div className="col-sm-4 zero-side-padding">
                        <Form.Label column={true}>Project</Form.Label>
                    </div>
                    <div className="col-sm-7">
                        <FormControl
                            className="input-wide"
                            disabled
                            type="text"
                            value={selectedProject ? selectedProject.description : ''}
                        />
                    </div>
                </div>
                <div className="row input-row">
                    <div className="col-sm-4 zero-side-padding">
                        <Form.Label column={true}>Research Coordinator</Form.Label>
                    </div>
                    <div className="col-sm-7">
                        <FormControl
                            className="input-wide"
                            disabled={!timeline.RowId || timeline.IsInUse}
                            id="RC"
                            onChange={handleChange}
                            type="text"
                            value={timeline.RC ? timeline.RC : ''}
                        />
                    </div>
                </div>
                <div className="row input-row">
                    <div className="col-sm-4 zero-side-padding">
                        <Form.Label column={true}>Lead Technician</Form.Label>
                    </div>
                    <div className="col-sm-7">
                        <FormControl
                            className="input-wide"
                            disabled={!timeline.RowId || timeline.IsInUse}
                            id="LeadTech"
                            onChange={handleChange}
                            type="text"
                            value={timeline.LeadTech ? timeline.LeadTech : ''}
                        />
                    </div>
                </div>
                <div className="row input-row">
                    <div className="col-sm-4 zero-side-padding">
                        <Form.Label column={true}>Animal Account</Form.Label>
                    </div>
                    <div className="col-sm-7">
                        <FormControl
                            className="input-wide"
                            disabled={!timeline.RowId || timeline.IsInUse}
                            id="AnimalAccount"
                            onChange={handleChange}
                            type="text"
                            value={timeline.AnimalAccount ? timeline.AnimalAccount : ''}
                        />
                    </div>
                </div>
            </div>
            <div className="col-sm-5 zero-left-padding">
                <div className="row input-row">
                    <div className="col-sm-6 zero-side-padding">
                        <div className="col-sm-5 zero-side-padding">
                            <Form.Label column={true}>Created</Form.Label>
                        </div>
                        <div className="col-sm-7 zero-side-padding">
                            <FormControl
                                className="input-wide"
                                id="Created"
                                readOnly={true}
                                type="date"
                                value={timeline.Created ? timeline.Created : ''}
                            />
                        </div>
                    </div>
                    <div className="col-sm-6 zero-side-padding">
                        <div className="col-sm-5 zero-side-padding">
                            <Form.Label column={true}>Created By</Form.Label>
                        </div>
                        <div className="col-sm-7 zero-side-padding">
                            <FormControl
                                className="input-wide"
                                id="CreatedByName"
                                readOnly={true}
                                type="text"
                                value={timeline.CreatedByName ? timeline.CreatedByName : ''}
                            />
                        </div>
                    </div>
                </div>
                <div className="row input-row">
                    <div className="col-sm-6 zero-side-padding">
                        <div className="col-sm-5 zero-side-padding">
                            <Form.Label column={true}>Modified</Form.Label>
                        </div>
                        <div className="col-sm-7 zero-side-padding">
                            <FormControl
                                className="input-wide"
                                id="Modified"
                                readOnly={true}
                                type="date"
                                value={timeline.Modified ? timeline.Modified : ''}
                            />
                        </div>
                    </div>
                    <div className="col-sm-6 zero-side-padding">
                        <div className="col-sm-5 zero-side-padding">
                            <Form.Label column={true}>Modified By</Form.Label>
                        </div>
                        <div className="col-sm-7 zero-side-padding">
                            <FormControl
                                className="input-wide"
                                id="ModifiedByName"
                                readOnly={true}
                                type="text"
                                value={timeline.ModifiedByName ? timeline.ModifiedByName : ''}
                            />
                        </div>
                    </div>
                </div>
                <div className="row input-row">
                    <div className="col-sm-6 zero-side-padding">
                        <div className="col-sm-5 zero-side-padding">
                            <Form.Label column={true}>Start</Form.Label>
                        </div>
                        <div className="col-sm-7 zero-side-padding">
                            <FormControl
                                className="input-wide"
                                disabled={!timeline.RowId || timeline.IsInUse}
                                id="StartDate"
                                onChange={handleChange}
                                type="date"
                                value={timeline.StartDate ? timeline.StartDate : ''}
                            />
                        </div>
                    </div>
                    <div className="col-sm-6 zero-side-padding">
                        <div className="col-sm-5 zero-side-padding">
                            <Form.Label column={true}>End</Form.Label>
                        </div>
                        <div className="col-sm-7 zero-side-padding">
                            <FormControl
                                className="input-wide"
                                disabled={!timeline.RowId || timeline.IsInUse}
                                id="EndDate"
                                onChange={handleChange}
                                type="date"
                                value={timeline.EndDate ? timeline.EndDate : ''}
                            />
                        </div>
                    </div>
                </div>
                <div className="row input-row">
                    <div className="col-sm-6 zero-side-padding">
                        <div className="col-sm-5 zero-side-padding">
                            <Form.Label column={true}>Study Day 0</Form.Label>
                        </div>
                        <div className="col-sm-7 zero-side-padding">
                            <FormControl
                                className="input-wide"
                                disabled={!timeline.RowId || timeline.RevisionNum > 0}
                                id="StudyDay0"
                                onChange={handleStudyDay0}
                                type="date"
                                value={timeline.StudyDay0 ? timeline.StudyDay0 : ''}
                            />
                        </div>
                    </div>
                    <div className="col-sm-6 zero-side-padding">
                        <div className="col-sm-5  zero-side-padding">
                            <Form.Label column={true}>Draft</Form.Label>
                        </div>
                        <div className="col-sm-7 zero-side-padding margin-small-top">
                            <input
                                checked={timeline.QcStateLabel ? timeline.QcStateLabel === 'In Progress' : false}
                                disabled={!timeline.RowId || timeline.IsInUse}
                                id="QcStateLabel"
                                onChange={handleDraftCheck}
                                style={{ width: '20px', height: '20px' }}
                                type="checkbox"
                            />
                        </div>
                    </div>
                </div>
            </div>
            <div className="col-sm-3 zero-right-padding">
                <div className="row">
                    <div className="col-sm-4">
                        <Form.Label className="wrap-words input-wide" column={true}>
                            Study Notes
                        </Form.Label>
                    </div>
                    <div className="col-sm-7 zero-side-padding">
                        <FormControl
                            as="textarea"
                            disabled={!timeline.RowId || timeline.IsInUse}
                            id="Notes"
                            onChange={handleChange}
                            value={timeline.Notes ? timeline.Notes : ''}
                        />
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-4">
                        <Form.Label className="wrap-words input-wide" column={true}>
                            Scheduler Notes
                        </Form.Label>
                    </div>
                    <div className="col-sm-7 zero-side-padding">
                        <FormControl
                            as="textarea"
                            disabled={!timeline.RowId || timeline.IsInUse}
                            id="SchedulerNotes"
                            onChange={handleChange}
                            value={timeline.SchedulerNotes ? timeline.SchedulerNotes : ''}
                        />
                    </div>
                </div>
            </div>
        </div>
    );
};

const mapStateToProps = (state: RootState) => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.timeline.selectedTimeline || null,
});

const mapDispatchToProps = (dispatch: any) => ({
    onUpdateSelectedTimeline: (timeline: Partial<Timeline>, dirty: boolean) =>
        dispatch(updateSelectedTimeline(timeline, dirty)),
    onUpdateTimelineDayZero: (day0: string, forceReload: boolean, dirty: boolean) =>
        dispatch(setTimelineDayZero(day0, forceReload, dirty)),
});

export default connect(mapStateToProps, mapDispatchToProps)(TimelineDetails);
