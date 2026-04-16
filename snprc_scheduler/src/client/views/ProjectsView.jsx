import React from 'react';
import { connect } from "react-redux";

import ProjectList from '../components/ProjectList';
import AnimalList from '../components/AnimalList';
import ProjectDetails from '../components/ProjectDetails';
import TimelineList from '../components/TimelineList';
import TimelineDetails from '../components/TimelineDetails';
import { Button, Modal, Accordion, Alert } from "react-bootstrap";
import CalendarDetails from "../components/CalendarDetails";
import AnimalDetails from "../components/AnimalDetails";
import ProjectMain from "../components/ProjectMain";
import TimelineGrid from "../components/TimelineGrid";
import AnimalMain from "../components/AnimalMain";

import {
    deleteNewTimelines,
    expandAccordionTab,
    hideAlertBanner,
    hideAlertModal,
    hideConfirm,
    hideLoading,
    saveTimeline,
    saveTimelineSuccess,
    selectFirstTimeline,
    selectTimeline,
    setForceRerender,
    setTimelineClean,
    showAlertBanner,
    showAlertModal,
    showConfirm,
    TAB_ANIMALS,
    TAB_PROJECTS,
    TAB_TIMELINES
} from '../actions/dataActions';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core'
import { faSpinner } from '@fortawesome/free-solid-svg-icons';
import Confirm from "../components/Confirm";
import AlertModal from "../components/AlertModal";

library.add(faSpinner)

class ProjectsView extends React.Component {
        
    constructor(props) {
        super(props);
        this.state = {
            showSaving: false
        };

        this.props.expandTab(TAB_PROJECTS);

        window.addEventListener("beforeunload", this.handleWindowBeforeUnload);
    }

    componentWillUnmount() {
        window.removeEventListener("beforeunload", this.handleWindowBeforeUnload);
    }

    handleWindowBeforeUnload = (event) => {

        if (this.props.selectedTimeline && this.props.selectedTimeline.IsDirty && (!this.props.confirm || !this.props.confirm.show)) {
            event.returnValue = 'Changes you made may not be saved.';
        }
    }

    handleAccordionSelectionChange = (tabIndex) => {
        const { selectedTimeline, selectTimeline, selectFirstTimeline, timelines, cleanTimeline, deleteNewTimelines,
            showConfirm, hideConfirm, expandTab, accordion, showAlertModal, hideAlertModal } = this.props;

        if (tabIndex != null) {
            switch (tabIndex) {
                case 0:
                    if (selectedTimeline && selectedTimeline.IsDirty) {
                        showConfirm({
                            title: 'Unsaved Data',
                            msg: 'Navigating away from this timeline will lose unsaved data, including the timeline itself if not saved. Proceed without saving?',
                            onConfirm: () => {
                                hideConfirm();
                                cleanTimeline(selectedTimeline);
                                this.setState({confirmed: true});
                                deleteNewTimelines();
                                selectTimeline();
                                expandTab(tabIndex);
                            },
                            onCancel: () => {
                                hideConfirm();
                            }
                        })
                    }
                    else {
                        selectTimeline();
                        expandTab(tabIndex);
                    }
                    break;
                case 1:
                    expandTab(tabIndex);
                    break;
                case 2:
                    if (!selectedTimeline) {
                        showAlertModal({
                            title: 'Select Timeline',
                            msg: 'Select or create a timeline before selecting animals.',
                            onDismiss: () => {
                                hideAlertModal();
                            }
                        })
                    } else {
                        expandTab(tabIndex);
                    }
                    break;
                default:
                    expandTab(tabIndex);
                    break;
            }
        }
    };
    
    getDetailComponent = (tabIndex) => {
        switch (tabIndex) {
            case TAB_PROJECTS: return <ProjectDetails />;
            case TAB_ANIMALS: return <AnimalDetails />;
            case TAB_TIMELINES: return <TimelineDetails />;
            default: return <CalendarDetails />;
        }
    };

    getMainComponent = (tabIndex) => {
        switch (tabIndex) {
            case TAB_PROJECTS: return <ProjectMain />;
            case TAB_ANIMALS: return  <AnimalMain />;
            case TAB_TIMELINES: return <TimelineGrid />;
            default: return <ProjectMain />;
        }
    };

    modalStyle = () => {

        return {
            position: 'fixed',
            width: 400,
            zIndex: 1040,
            top: '35%',
            left: '45%',
            backgroundColor: 'transparent'
        };
    };

    cancel = () => {
        const { showConfirm, hideConfirm } = this.props;

        showConfirm({
            title: 'Unsaved Data',
            msg: 'Any unsaved data will be lost and the page will reload.  Are you sure?',
            onConfirm: () => {
                location.reload();
            },
            onCancel: () => {
                hideConfirm();
            }
        });
    };

    save = () => {
        return () => {
            const { showAlertBanner, selectedTimeline, onSaveSuccess } = this.props;

            // Validate Study Day 0 is set when not in draft mode
            if (selectedTimeline.QcStateLabel !== 'In Progress' && !selectedTimeline.StudyDay0) {
                showAlertBanner({
                    variant: 'danger',
                    msg: 'Study Day 0 is required when saving a timeline that is not in draft mode.'
                });
                return;
            }

            // Validate Study Day 0 is not before Start Date for revision 0 non-draft timelines
            if (selectedTimeline.RevisionNum === 0
                && selectedTimeline.QcStateLabel !== 'In Progress'
                && selectedTimeline.StudyDay0
                && selectedTimeline.StartDate
                && new Date(selectedTimeline.StudyDay0) < new Date(selectedTimeline.StartDate)) {
                showAlertBanner({
                    variant: 'danger',
                    msg: 'Study Day 0 cannot be before the Start Date for an original timeline that is not in draft mode.'
                });
                return;
            }

            selectedTimeline.IsDirty = true;

            this.setState({ showSaving: true });

            return saveTimeline(selectedTimeline).then((response) => {


                if (!response.success) {
                    if (response.responseText) {
                        showAlertBanner({variant: 'danger', msg: "Error saving " + selectedTimeline.Description +
                                    ", revision " + selectedTimeline.RevisionNum + ": " + response.responseText});
                        console.warn('save timeline error', response.responseText);
                    }
                    else {
                        showAlertBanner({variant: 'danger', msg: "Error saving " + selectedTimeline.Description +
                                    ", revision " + selectedTimeline.RevisionNum + ": Success value false"});
                        console.warn('save timeline error', "success value false");
                    }
                }
                else {
                    // console.log('save timeline succeeded');
                    showAlertBanner({variant: 'success', msg: selectedTimeline.Description + ", revision " + selectedTimeline.RevisionNum +
                        " saved successfully."});
                    onSaveSuccess(response.rows);
                }

                this.setState({ showSaving: false });

                this.props.hideLoading();

            }).catch((error) => {

                if (error.exception) {
                    showAlertBanner({variant: 'danger', msg: "Error saving " + selectedTimeline.Description +
                                ", revision " + selectedTimeline.RevisionNum + ": " + error.exception});
                    console.warn('save timeline error', error.exception);
                }
                else if (error.errors) {
                    showAlertBanner({variant: 'danger', msg: "Error saving " + selectedTimeline.Description +
                                ", revision " + selectedTimeline.RevisionNum + ": " + error.errors[0].msg});
                    console.warn('save timeline error', error.errors[0].msg);
                }
                else if (error.message) {
                    showAlertBanner({variant: 'danger', msg: "Error saving " + selectedTimeline.Description +
                                ", revision " + selectedTimeline.RevisionNum + ": " + error.message});
                    console.warn('save timeline error', error.message);
                }

                this.setState({ showSaving: false });

                this.props.hideLoading();
            });
        };
    };

    forceRerenderHandler = () => {
        this.props.setForceRerender(true);
    }

    dismissBanner = () => {
        this.props.hideAlertBanner();
    }

    LoadingModal = (show) => {
        return (
                <Modal
                        show={show}
                        // show={true}
                        backdrop="static"
                        keyboard={false}
                        centered
                        animation={false}
                        className="loading-modal"
                >
                    <Modal.Body className="text-center py-5">
                        <FontAwesomeIcon icon={faSpinner} size={"9x"} spinPulse={true}/>
                          {/*<h4>Loading...</h4>*/}
                          <p className="margin-top">Loading. Please wait...</p>
                    </Modal.Body>
                </Modal>

        );
    }

    render() {

        const { selectedProject, selectedTimeline, confirm, alertModal, alertBanner, accordion, hasPermission, showLoading } = this.props;

        let detailView = this.getDetailComponent(accordion ? accordion.tab : null);
        let mainView = this.getMainComponent(accordion ? accordion.tab : null);
        let accordionComponent = (
            <Accordion
                    id="accordion-controller"
                    activeKey={accordion ? accordion.tab : TAB_PROJECTS}
                    onSelect={this.handleAccordionSelectionChange}
                    className = 'scheduler-bs-accordion'
                    style={{marginLeft: '20px'}}
                    >
                <Accordion.Item eventKey={TAB_PROJECTS}>
                    <Accordion.Header>
                        <div className='scheduler-bs-accordion-title'>{'Projects' +
                            ((selectedProject && selectedProject.description)
                            ? (' - ' + selectedProject.description) : '')}
                        </div>
                    </Accordion.Header>
                    <Accordion.Body onEntered={this.forceRerenderHandler}><ProjectList store={this.props.store} /></Accordion.Body>
                </Accordion.Item>
                <Accordion.Item eventKey={TAB_TIMELINES} className='scheduler-accordion-timeline-item'>
                    <Accordion.Header>
                        <div className='scheduler-bs-accordion-title'>{'Timelines' +
                            ((selectedTimeline && selectedTimeline.Description)
                            ? (' - ' + selectedTimeline.Description) : '') + (selectedTimeline && selectedTimeline.savedDraft ? " (draft)" : "")}
                        </div>
                    </Accordion.Header>
                    <Accordion.Body><TimelineList /></Accordion.Body>
                </Accordion.Item>
                <Accordion.Item eventKey={TAB_ANIMALS}>
                    <Accordion.Header>
                        <div>Animals</div>
                    </Accordion.Header>
                    <Accordion.Body onEntered={this.forceRerenderHandler}><AnimalList store={this.props.store}/></Accordion.Body>
            </Accordion.Item>
            </Accordion>
        );

        return <div className='scheduler-view'>
            { this.LoadingModal(this.state.showSaving || showLoading) }
            <Confirm show={confirm ? confirm.show : false}
                           title={confirm ? confirm.title : ''}
                           msg={confirm ? confirm.msg : ''}
                           onConfirm={confirm ? confirm.onConfirm : null}
                           onCancel={confirm ? confirm.onCancel : null}
                           confirmButtonText='Yes'
                           cancelButtonText='No'
                           confirmVariant='danger'/>
            <AlertModal show={alertModal ? alertModal.show : false}
                     title={alertModal ? alertModal.title : ''}
                     msg={alertModal ? alertModal.msg : ''}
                     onDismiss={alertModal ? alertModal.onDismiss : null}
                     dismissButtonText='OK'/>
            { alertBanner && alertBanner.show &&
            <Alert variant={alertBanner.variant}
                   dismissible={true}
                   // className={"alert-banner alert alert-" + alertBanner.variant}
                   onClose={this.dismissBanner}>{alertBanner.msg}</Alert>
            }

            {(!alertBanner || !alertBanner.show) && <><div className='row spacer-row'></div></>}
            {hasPermission &&
                <div className='projects-view'>
                    <div className='col-sm-12 zero-right-padding projects-view-top'>{detailView}</div>
                    <div className='projects-view-main'>
                        <div className='col-sm-4'>{accordionComponent}</div>
                        <div className='col-sm-8 zero-side-padding'>{mainView}</div>
                    </div>
                    <div className='projects-view-bottom'>
                        <div className='scheduler-save-cancel padding-top'>
                            <div className='col-sm-2'>
                                <Button variant='primary' disabled={this.props.selectedTimeline == null || this.props.selectedTimeline.RevisionNum == null}
                                        onClick={this.props.selectedTimeline ? this.save() : null}
                                        className='scheduler-save-cancel-btn'>Save</Button>
                            </div>
                            <div className='col-sm-2'><Button variant='primary' onClick={this.cancel}
                                                              className='scheduler-save-cancel-btn'>Cancel</Button></div>
                        </div>
                    </div>
                </div>
            }
        </div>

    }

  }

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.timeline.selectedTimeline || null,
    timelines: state.timeline.timelines,
    confirm: state.root.confirm,
    alertModal: state.root.alertModal,
    alertBanner: state.root.alertBanner,
    accordion: state.root.accordion,
    showLoading: state.root.showLoading,
    hasPermission: state.root.hasPermission
})

const mapDispatchToProps = dispatch => ({
    // selectFirstTimeline: timelines => dispatch(selectFirstTimeline(timelines)),
    selectFirstTimeline: (timelines) => (dispatch) => {
        return dispatch(selectFirstTimeline(timelines)) },

    onSaveSuccess: timeline => dispatch(saveTimelineSuccess(timeline)),
    showAlertBanner: alert => dispatch(showAlertBanner(alert)),
    hideAlertBanner: () => dispatch(hideAlertBanner()),
    showAlertModal: alert => dispatch(showAlertModal(alert)),
    hideAlertModal: () => dispatch(hideAlertModal()),
    hideLoading: () => dispatch(hideLoading()),
    selectTimeline: timeline => dispatch(selectTimeline(timeline)),
    showConfirm: confirm => dispatch(showConfirm(confirm)),
    hideConfirm: confirm => dispatch(hideConfirm(confirm)),
    cleanTimeline: timeline => dispatch(setTimelineClean(timeline)),
    deleteNewTimelines: timeline => dispatch(deleteNewTimelines(timeline)),
    expandTab: tab => dispatch(expandAccordionTab(tab)),
    setForceRerender: tab => dispatch(setForceRerender(tab))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(ProjectsView)
