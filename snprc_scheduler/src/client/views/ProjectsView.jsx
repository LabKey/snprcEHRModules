import React from 'react';
import {connect} from "react-redux";

import ProjectList from '../components/ProjectList';
import AnimalList from '../components/AnimalList';
import ProjectDetails from '../components/ProjectDetails';
import TimelineList from '../components/TimelineList';
import TimelineDetails from '../components/TimelineDetails';
import {Accordion, Card, Button, Modal, Panel, PanelGroup} from "react-bootstrap";
import CalendarDetails from "../components/CalendarDetails";
import AnimalDetails from "../components/AnimalDetails";
import ProjectMain from "../components/ProjectMain";
import TimelineGrid from "../components/TimelineGrid";
import CalendarList from "../components/CalendarList";
import AnimalMain from "../components/AnimalMain";

import {
    saveTimeline, saveTimelineSuccess
} from '../actions/dataActions';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core'
import { faSpinner } from '@fortawesome/free-solid-svg-icons';

library.add(faSpinner)

const TAB_PROJECTS = 0x0;
const TAB_TIMELINES = 0x1;
const TAB_ANIMALS = 0x2;
const TAB_CALENDAR = 0x3;

class ProjectsView extends React.Component {
        
    constructor(props) {
        super(props);
        this.state = {
            selectedTab: TAB_PROJECTS,
            showSaving: false
        };
    }

    handleAccordionSelectionChange = (tabIndex) => {
        if (tabIndex != null) {
            this.setState({selectedTab: tabIndex});
        }
    };

    shouldComponentUpdate(nextProps, nextState, nextContext) {
        return true;
    };
    
    getDetailComponent = (tabIndex) => {
        switch (tabIndex) {
            case TAB_PROJECTS: return <ProjectDetails />;
            case TAB_ANIMALS: return <AnimalDetails />;
            case TAB_TIMELINES: return <TimelineDetails />;
            case TAB_CALENDAR: return <CalendarDetails />;
            default: return <CalendarDetails />;
        }
    };

    getMainComponent = (tabIndex) => {
        switch (tabIndex) {
            case TAB_PROJECTS: return <ProjectMain />;
            case TAB_ANIMALS: return  <AnimalMain />;
            case TAB_TIMELINES: return <TimelineGrid />;
            case TAB_CALENDAR: return <AnimalMain />;
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
        let r = confirm('Any unsaved data will be lost and the page will reload.  Are you sure?');
        if (r === true) {
            location.reload();
        }
    }

    save = () => {
        return () => {
            const timeline = this.props.selectedTimeline;
            timeline.IsDirty = true;

            this.setState(state => {
                state.showSaving = true;
                return state;
            });

            return saveTimeline(timeline).then((response) => {
                this.setState(state => {
                    state.showSaving = false;
                    return state;
                });

                if (!response.success) {
                    if (response.responseText) {
                        alert("Error on save: " + response.responseText);
                        console.warn('save project error', response.responseText);
                    }
                    else {
                        alert("Error on save: Success value false");
                        console.warn('save project error', "success value false");
                    }
                }
                else {
                    console.log('save timeline succeeded');
                    this.props.onSaveSuccess(response.rows);
                }

            }).catch((error) => {
                this.setState(state => {
                    state.showSaving = false;
                    return state;
                });

                if (error.exception) {
                    alert("Error on save: " + error.exception);
                    console.warn('save project error', error.exception);
                }
                else if (error.errors) {
                    alert("Error on save: " + error.errors[0].msg);
                    console.warn('save project error', error.errors[0].msg);
                }
            });
        };
    };

    formatAccordionTitle = (title) => {
        let formatted = title;
        // if (title && title.length > 25) {
        //     formatted = title.substring(0, 25);
        //     formatted += '...';
        // }

        return formatted;
    };

    render() {

        const { selectedProject, selectedTimeline } = this.props;

        let detailView = this.getDetailComponent(this.state.selectedTab);
        let mainView = this.getMainComponent(this.state.selectedTab);
        let accordionComponent = (
            <PanelGroup
                    accordion
                    id="accordion-controller"
                    activeKey={this.state.selectedTab}
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
                    <Panel.Body collapsible><ProjectList store={this.props.store} /></Panel.Body>
                </Panel>
                <Panel eventKey={TAB_TIMELINES}>
                    <Panel.Heading>
                        <Panel.Title toggle className='scheduler-bs-accordion-title'>{'Timelines' +
                            ((selectedTimeline && selectedTimeline.Description)
                            ? (' - ' + selectedTimeline.Description) : '')}
                        </Panel.Title>
                    </Panel.Heading>
                    <Panel.Body collapsible><TimelineList /></Panel.Body>
                </Panel>
                <Panel eventKey={TAB_ANIMALS}>
                    <Panel.Heading>
                        <Panel.Title toggle>Animals</Panel.Title>
                    </Panel.Heading>
                    <Panel.Body collapsible><AnimalList store={this.props.store} /></Panel.Body>
                </Panel>
            </PanelGroup>
        );
        return <div className='scheduler-view'>
            <Modal
                    // onHide={this.close}
                    style={this.modalStyle()}
                    aria-labelledby="modal-label"
                    show={this.state.showSaving}
                    renderBackdrop={this.renderBackdrop}
                    className={'timeline-saving-modal'}
            >
                <div style={{backgroundColor: 'transparent'}}>
                    <FontAwesomeIcon icon={["fa", "spinner"]} size={"9x"} pulse/>
                </div>
            </Modal>
            <div className='row spacer-row'></div>
            <div className='row'>
                <div className='col-sm-12 zero-right-padding'>{detailView}</div>
                <div className='col-sm-4'>
                    <div className='col-sm-12'>
                        {accordionComponent}
                    </div>
                    <div className='scheduler-save-cancel'>
                        <div className='col-sm-6'>
                            <Button disabled={this.props.selectedTimeline == null || this.props.selectedTimeline.RevisionNum == null} onClick={this.props.selectedTimeline ? this.save() : null} className='scheduler-save-cancel-btn'>Save</Button>
                        </div>
                        <div className='col-sm-6'> <Button onClick={this.cancel} className='scheduler-save-cancel-btn'>Cancel</Button> </div>
                    </div>
                </div>
                <div className='col-sm-8 zero-side-padding'>{mainView}</div>
            </div>
        </div>
    }

  }

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject || null,
    selectedTimeline: state.timeline.selectedTimeline || null
})

const mapDispatchToProps = dispatch => ({
    onSaveSuccess: timeline => dispatch(saveTimelineSuccess(timeline))
})

export default connect(
        mapStateToProps,
        mapDispatchToProps
)(ProjectsView)
