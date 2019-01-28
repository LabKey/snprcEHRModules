import React from 'react';
import connect from "react-redux/es/connect/connect";
import {ControlLabel, FormControl} from "react-bootstrap";

class ProjectDetails extends React.Component {

    render() {
        if (this.props.selectedProject != null) {
            return (<div className='container-fluid details-frame' style={{textAlign: 'left'}}>
                <div className='row input-row'>
                    <div className='col-sm-4'>
                        <div className='row input-row'>
                            <div className='col-sm-4'><ControlLabel>Cost Account</ControlLabel></div>
                            <div className='col-sm-6'><FormControl type='text' className='input-wide' id="CostAccount" readOnly
                                                             value={this.props.selectedProject.CostAccount || ''}/>
                            </div>
                        </div>
                        <div className='row input-row'>
                            <div className='col-sm-4'><ControlLabel>Charge ID</ControlLabel></div>
                            <div className='col-sm-6'><FormControl type='text' className='input-wide' id="referenceId"readOnly
                                                             value={this.props.selectedProject.referenceId || ''}/>
                            </div>
                        </div>
                        <div className='row input-row'>
                            <div className='col-sm-4'><ControlLabel>IACUC</ControlLabel></div>
                            <div className='col-sm-6'><FormControl type='text' className='input-wide' id="Iacuc" readOnly
                                                             value={this.props.selectedProject.Iacuc || ''}/></div>
                        </div>
                    </div>
                    <div className='col-sm-4'>
                        <div className='row input-row'>
                            <div className='col-sm-4'><ControlLabel>Primary Vet</ControlLabel></div>
                            <div className='col-sm-6'><FormControl type='text' className='input-wide' id="Veterinarian1" readOnly
                                                             value={this.props.selectedProject.Veterinarian1 || ''}/>
                            </div>
                        </div>

                        <div className='row input-row'>
                            <div className='col-sm-4'><ControlLabel>Secondary Vet</ControlLabel></div>
                            <div className='col-sm-6'><FormControl type='text' className='input-wide' id="Veterinarian2" readOnly
                                                             value={this.props.selectedProject.Veterinarian2 || ''}/>
                            </div>
                        </div>

                        <div className='row input-row'>
                            <div className='col-sm-4'><ControlLabel>VS Number</ControlLabel></div>
                            <div className='col-sm-6'><FormControl type='text' className='input-wide' id="VsNumber" readOnly
                                                             value={this.props.selectedProject.VsNumber || ''}/></div>
                        </div>
                    </div>
                    <div className='col-sm-4'>
                        <div className='row input-row'>
                            <div className='col-sm-4'><ControlLabel>Start Date</ControlLabel></div>
                            <div className='col-sm-6'><FormControl type='text' className='input-wide' id="startDate" readOnly
                                                             value={this.props.selectedProject.startDate || ''}/></div>
                        </div>

                        <div className='row input-row'>
                            <div className='col-sm-4'><ControlLabel>End Date</ControlLabel></div>
                            <div className='col-sm-6'><FormControl type='text' className='input-wide' id="endDate" readOnly
                                                             value={this.props.selectedProject.endDate || ''}/></div>
                        </div>
                    </div>
                </div>
            </div>)
        } else {
            return <div className='details-frame'>Please select a project to view it's details</div>
        }

    }
}

const mapStateToProps = state => ({
    selectedProject: state.project.selectedProject
});

export default connect(
        mapStateToProps
)(ProjectDetails)