import React from 'react';
import {connect} from "react-redux";

import ProjectList from '../components/ProjectList';
import AnimalList from '../components/AnimalList';
import ProjectDetails from '../components/ProjectDetails';
import TimelineList from '../components/TimelineList';
import TimelineDetails from '../components/TimelineDetails';
import {Panel, PanelGroup} from "react-bootstrap";
import CalendarDetails from "../components/CalendarDetails";
import AnimalDetails from "../components/AnimalDetails";
import ProjectMain from "../components/ProjectMain";
import TimelineGrid from "../components/TimelineGrid";

const TAB_PROJECTS = 0x0;
const TAB_TIMELINES = 0x1;
const TAB_ANIMALS = 0x2;
const TAB_CALENDAR = 0x3;

class ProjectsView extends React.Component {
        
    constructor(props) {
        super(props);
        this.state = { selectedTab: TAB_PROJECTS };
    }

    handleAccordionSelectionChange = (tabIndex) => this.setState({ selectedTab: tabIndex });
    
    getDetailComponent = (tabIndex) => {
        switch (tabIndex) {
            case TAB_PROJECTS: return <ProjectDetails />;
            case TAB_ANIMALS: return <AnimalDetails />;
            case TAB_TIMELINES: return <TimelineDetails />;
            case TAB_CALENDAR: return <CalendarDetails />;
            default: return <CalendarDetails />;
        }
    }

    getMainComponent = (tabIndex) => {
        switch (tabIndex) {
            case TAB_PROJECTS: return <ProjectMain />;
            case TAB_ANIMALS: return  <ProjectMain />;
            case TAB_TIMELINES: return <TimelineGrid />;
            case TAB_CALENDAR: return <ProjectMain />;
            default: return <ProjectMain />;
        }
    }

    render() {

        let detailView = this.getDetailComponent(this.state.selectedTab);
        let mainView = this.getMainComponent(this.state.selectedTab);
        let accordionComponent = (
            <PanelGroup
                    accordion
                    id="accordion-controller"
                    activeKey={this.state.selectedTab}
                    onSelect={this.handleAccordionSelectionChange}
                    className = 'bs-accordion'
                    style={{marginLeft: '20px'}}
                    >
                <Panel eventKey={TAB_PROJECTS}>
                    <Panel.Heading>
                        <Panel.Title toggle>Projects</Panel.Title>
                    </Panel.Heading>
                    <Panel.Body collapsible><ProjectList store={this.props.store} /></Panel.Body>
                </Panel>
                <Panel eventKey={TAB_TIMELINES}>
                    <Panel.Heading>
                        <Panel.Title toggle>Timelines</Panel.Title>
                    </Panel.Heading>
                    <Panel.Body collapsible><TimelineList /></Panel.Body>
                </Panel>
                <Panel eventKey={TAB_ANIMALS}>
                    <Panel.Heading>
                        <Panel.Title toggle>Animals</Panel.Title>
                    </Panel.Heading>
                    <Panel.Body collapsible><AnimalList store={this.props.store} /></Panel.Body>
                </Panel>
                <Panel eventKey={TAB_CALENDAR}>
                    <Panel.Heading>
                        <Panel.Title toggle>Calendar</Panel.Title>
                    </Panel.Heading>
                    <Panel.Body collapsible>Calendar Content</Panel.Body>
                </Panel>
            </PanelGroup>
        );
        return <div>
            <div className='row spacer-row'></div>
            <div className='row'>
                <div className='col-sm-12'>{detailView}</div>
                <div className='col-sm-3'>{accordionComponent}</div>
                <div className='col-sm-9'>{mainView}</div>
            </div>
        </div>
    }

  }

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject
})

export default connect(
        mapStateToProps
)(ProjectsView)
