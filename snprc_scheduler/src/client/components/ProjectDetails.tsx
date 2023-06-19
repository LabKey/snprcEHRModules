import React from 'react';
import { connect } from 'react-redux';
import { ControlLabel, FormControl } from 'react-bootstrap';

import { AppState } from '../reducers';

class ProjectDetails extends React.Component<any> {

    render() {
        const { selectedProject } = this.props;

        return (
            <div className="container-fluid details-frame project-details" style={{ textAlign: 'left' }}>
                <div className="col-sm-4">
                    <div className="row input-row">
                        <div className="col-sm-3 zero-side-padding"><ControlLabel>Cost Account</ControlLabel></div>
                        <div className="col-sm-7"><FormControl type="text" className="input-wide" id="CostAccount" readOnly
                                                               value={selectedProject && selectedProject.CostAccount ? selectedProject.CostAccount : ""}/>
                        </div>
                        <div className="col-sm-1" />
                    </div>
                    <div className="row input-row">
                        <div className="col-sm-3 zero-side-padding"><ControlLabel>Charge ID</ControlLabel></div>
                        <div className="col-sm-7"><FormControl type="text" className="input-wide" id="referenceId" readOnly
                                                               value={selectedProject && selectedProject.referenceId ? selectedProject.referenceId : ""}/>
                        </div>
                        <div className="col-sm-1" />
                    </div>
                    <div className="row input-row">
                        <div className="col-sm-3 zero-side-padding"><ControlLabel>IACUC</ControlLabel></div>
                        <div className="col-sm-7"><FormControl type="text" className="input-wide" id="Iacuc" readOnly
                                                               value={selectedProject && selectedProject.Iacuc ? selectedProject.Iacuc : ""}/>
                        </div>
                        <div className="col-sm-1" />
                    </div>
                </div>
                <div className="col-sm-4">
                    <div className="row input-row">
                        <div className="col-sm-3 zero-side-padding"><ControlLabel>Primary Vet</ControlLabel></div>
                        <div className="col-sm-7"><FormControl type="text" className="input-wide" id="Veterinarian1"
                                                               readOnly
                                                               value={selectedProject && selectedProject.Veterinarian1 ? selectedProject.Veterinarian1 : ""}/>
                        </div>
                    </div>

                    <div className="row input-row">
                        <div className="col-sm-3 zero-side-padding"><ControlLabel>Secondary Vet</ControlLabel></div>
                        <div className="col-sm-7"><FormControl type="text" className="input-wide" id="Veterinarian2"
                                                               readOnly
                                                               value={selectedProject && selectedProject.Veterinarian2 ? selectedProject.Veterinarian2 : ""}/>
                        </div>
                    </div>

                    <div className="row input-row">
                        <div className="col-sm-3 zero-side-padding"><ControlLabel>VS Number</ControlLabel></div>
                        <div className="col-sm-7"><FormControl type="text" className="input-wide" id="VsNumber" readOnly
                                                               value={selectedProject && selectedProject.VsNumber ? selectedProject.VsNumber : ""}/>
                        </div>
                    </div>
                </div>
                <div className="col-sm-4 zero-right-padding">
                    <div className="row input-row">
                        <div className="col-sm-3 zero-side-padding"><ControlLabel>Start Date</ControlLabel></div>
                        <div className="col-sm-7"><FormControl type="text" className="input-wide" id="startDate" readOnly
                                                               value={selectedProject && selectedProject.startDate ? selectedProject.startDate : ""}/>
                        </div>
                        <div className="col-sm-1" />
                    </div>

                    <div className="row input-row">
                        <div className="col-sm-3 zero-side-padding"><ControlLabel>End Date</ControlLabel></div>
                        <div className="col-sm-7">
                            <FormControl
                                type="text"
                                className="input-wide"
                                id="endDate"
                                readOnly
                                value={selectedProject && selectedProject.endDate ? selectedProject.endDate : ""}
                            />
                        </div>
                        <div className="col-sm-1" />
                    </div>
                </div>
            </div>
        );
    }
}

const mapStateToProps = (state: AppState) => ({
    selectedProject: state.project.selectedProject,
});

export default connect(mapStateToProps)(ProjectDetails);
