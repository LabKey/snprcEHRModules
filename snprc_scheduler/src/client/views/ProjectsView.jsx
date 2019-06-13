import React from 'react';
import {connect} from "react-redux";

import ProjectList from '../components/ProjectList';
import AnimalList from '../components/AnimalList';
import ProjectDetails from '../components/ProjectDetails';
import TimelineList from '../components/TimelineList';
import TimelineDetails from '../components/TimelineDetails';
import {Card, Button, Modal, Panel, PanelGroup, Alert} from "react-bootstrap";
import CalendarDetails from "../components/CalendarDetails";
import AnimalDetails from "../components/AnimalDetails";
import ProjectMain from "../components/ProjectMain";
import TimelineGrid from "../components/TimelineGrid";
import AnimalMain from "../components/AnimalMain";

import {
    deleteNewTimelines,
    expandAccordionTab,
    hideAlertBanner, hideAlertModal,
    hideConfirm,
    saveTimeline,
    saveTimelineSuccess, selectFirstTimeline,
    selectTimeline, setForceRerender, setProjectRender,
    setTimelineClean,
    showAlertBanner, showAlertModal,
    showConfirm, TAB_ANIMALS,
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

        if (this.props.selectedTimeline.IsDirty && (!this.props.confirm || !this.props.confirm.show)) {
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

                    // Select first timeline if going from project to timelines
                    if (accordion.tab === 0) {
                        selectFirstTimeline(timelines);
                    }
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

    backdropStyle = () => {

        return {
            position: 'fixed',
            zIndex: 1040,
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            backgroundColor: '#000',
            opacity: 0.5
        }
    };

    renderBackdrop = (props) => {
        return <div {...props} style={this.backdropStyle()}/>;
    }

    cancel = () => {
        this.props.showConfirm({
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
            const {showAlertBanner, selectedTimeline} = this.props;
            selectedTimeline.IsDirty = true;

            this.setState(state => {
                state.showSaving = true;
                return state;
            });

            return saveTimeline(selectedTimeline).then((response) => {
                this.setState(state => {
                    state.showSaving = false;
                    return state;
                });

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
                    console.log('save timeline succeeded');
                    showAlertBanner({variant: 'success', msg: selectedTimeline.Description + ", revision " + selectedTimeline.RevisionNum +
                        " saved successfully."});
                    this.props.onSaveSuccess(response.rows);
                }

            }).catch((error) => {
                this.setState(state => {
                    state.showSaving = false;
                    return state;
                });

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
            });
        };
    };

    forceRerenderHandler = () => {
        this.props.setForceRerender(true);
    }

    dismissBanner = () => {
        this.props.hideAlertBanner();
    }

    render() {

        const { selectedProject, selectedTimeline, confirm, alertModal, alertBanner, accordion, hasPermission, showLoading } = this.props;

        let detailView = this.getDetailComponent(accordion ? accordion.tab : null);
        let mainView = this.getMainComponent(accordion ? accordion.tab : null);
        let accordionComponent = (
            <PanelGroup
                    accordion
                    id="accordion-controller"
                    activeKey={accordion ? accordion.tab : TAB_PROJECTS}
                    onSelect={this.handleAccordionSelectionChange}
                    className = 'scheduler-bs-accordion'
                    style={{marginLeft: '20px'}}
                    >
                <Panel eventKey={TAB_PROJECTS}>
                    <Panel.Heading>
                        <Panel.Title toggle className='scheduler-bs-accordion-title'>{'Projects' +
                            ((selectedProject && selectedProject.description)
                            ? (' - ' + selectedProject.description) : '')}
                        </Panel.Title>
                    </Panel.Heading>
                    <Panel.Collapse onEntered={this.forceRerenderHandler}>
                        <Panel.Body><ProjectList store={this.props.store} /></Panel.Body>
                    </Panel.Collapse>
                </Panel>
                <Panel eventKey={TAB_TIMELINES}>
                    <Panel.Heading>
                        <Panel.Title toggle className='scheduler-bs-accordion-title'>{'Timelines' +
                            ((selectedTimeline && selectedTimeline.Description)
                            ? (' - ' + selectedTimeline.Description) : '') + (selectedTimeline && selectedTimeline.savedDraft ? " (draft)" : "")}
                        </Panel.Title>
                    </Panel.Heading>
                    <Panel.Body collapsible><TimelineList /></Panel.Body>
                </Panel>
                <Panel eventKey={TAB_ANIMALS}>
                <Panel.Heading>
                    <Panel.Title toggle>Animals</Panel.Title>
                </Panel.Heading>
                <Panel.Collapse onEntered={this.forceRerenderHandler}>
                    <Panel.Body><AnimalList store={this.props.store}/></Panel.Body>
                </Panel.Collapse>
            </Panel>
            </PanelGroup>
        );

        return <div className='scheduler-view'>
            <Modal
                    // onHide={this.close}
                    style={this.modalStyle()}
                    aria-labelledby="modal-label"
                    show={this.state.showSaving || showLoading}
                    renderBackdrop={this.renderBackdrop}
                    className={'timeline-saving-modal'}
            >
                <div style={{backgroundColor: 'transparent'}}>
                    <FontAwesomeIcon icon={["fa", "spinner"]} size={"9x"} pulse/>
                </div>
            </Modal>
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
            {alertBanner && alertBanner.show &&
            <Alert className="alert-banner" bsClass={'alert alert-' + alertBanner.variant} onDismiss={this.dismissBanner}>{alertBanner.msg}</Alert>
            }

            {(!alertBanner || !alertBanner.show) && <><div className='row spacer-row'></div></>}
            {hasPermission &&
                <div className='row'>
                    <div className='col-sm-12 zero-right-padding'>{detailView}</div>
                    <div className='col-sm-4'>
                        <div className='col-sm-12'>
                            {accordionComponent}
                        </div>
                        <div className='scheduler-save-cancel'>
                            <div className='col-sm-6'>
                                <Button disabled={this.props.selectedTimeline == null || this.props.selectedTimeline.RevisionNum == null}
                                        onClick={this.props.selectedTimeline ? this.save() : null}
                                        className='scheduler-save-cancel-btn'>Save</Button>
                            </div>
                            <div className='col-sm-6'><Button onClick={this.cancel}
                                                              className='scheduler-save-cancel-btn'>Cancel</Button></div>
                        </div>
                    </div>
                    <div className='col-sm-8 zero-side-padding'>{mainView}</div>
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
    onSaveSuccess: timeline => dispatch(saveTimelineSuccess(timeline)),
    showAlertBanner: alert => dispatch(showAlertBanner(alert)),
    hideAlertBanner: () => dispatch(hideAlertBanner()),
    showAlertModal: alert => dispatch(showAlertModal(alert)),
    hideAlertModal: () => dispatch(hideAlertModal()),
    selectTimeline: timeline => dispatch(selectTimeline(timeline)),
    selectFirstTimeline: timelines => dispatch(selectFirstTimeline(timelines)),
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
