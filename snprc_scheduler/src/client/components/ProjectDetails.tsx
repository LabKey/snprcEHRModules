import React, { FC } from 'react';
import { connect } from 'react-redux';
import { Form, FormControl } from 'react-bootstrap';
import { Project } from '../models/models';

interface ProjectDetailsProps {
    selectedProject: null | Project;
}

interface RootState {
    project: {
        selectedProject: null | Project;
    };
}

const ProjectDetails: FC<ProjectDetailsProps> = ({ selectedProject }) => {
    return (
        <div className="container-fluid details-frame project-details" style={{ textAlign: 'left' }}>
            <div className="col-sm-4">
                <div className="row input-row">
                    <div className="col-sm-3 zero-side-padding">
                        <Form.Label column={true}>Cost Account</Form.Label>
                    </div>
                    <div className="col-sm-7">
                        <FormControl
                            className="input-wide"
                            id="CostAccount"
                            readOnly
                            type="text"
                            value={selectedProject && selectedProject.CostAccount ? selectedProject.CostAccount : ''}
                        />
                    </div>
                    <div className="col-sm-1" />
                </div>
                <div className="row input-row">
                    <div className="col-sm-3 zero-side-padding">
                        <Form.Label column={true}>Charge ID</Form.Label>
                    </div>
                    <div className="col-sm-7">
                        <FormControl
                            className="input-wide"
                            id="referenceId"
                            readOnly
                            type="text"
                            value={selectedProject && selectedProject.referenceId ? selectedProject.referenceId : ''}
                        />
                    </div>
                    <div className="col-sm-1" />
                </div>
                <div className="row input-row">
                    <div className="col-sm-3 zero-side-padding">
                        <Form.Label column={true}>IACUC</Form.Label>
                    </div>
                    <div className="col-sm-7">
                        <FormControl
                            className="input-wide"
                            id="Iacuc"
                            readOnly
                            type="text"
                            value={selectedProject && selectedProject.Iacuc ? selectedProject.Iacuc : ''}
                        />
                    </div>
                    <div className="col-sm-1" />
                </div>
            </div>
            <div className="col-sm-4">
                <div className="row input-row">
                    <div className="col-sm-3 zero-side-padding">
                        <Form.Label column={true}>Primary Vet</Form.Label>
                    </div>
                    <div className="col-sm-7">
                        <FormControl
                            className="input-wide"
                            id="Veterinarian1"
                            readOnly
                            type="text"
                            value={
                                selectedProject && selectedProject.Veterinarian1 ? selectedProject.Veterinarian1 : ''
                            }
                        />
                    </div>
                </div>

                <div className="row input-row">
                    <div className="col-sm-3 zero-side-padding">
                        <Form.Label column={true}>Secondary Vet</Form.Label>
                    </div>
                    <div className="col-sm-7">
                        <FormControl
                            className="input-wide"
                            id="Veterinarian2"
                            readOnly
                            type="text"
                            value={
                                selectedProject && selectedProject.Veterinarian2 ? selectedProject.Veterinarian2 : ''
                            }
                        />
                    </div>
                </div>

                <div className="row input-row">
                    <div className="col-sm-3 zero-side-padding">
                        <Form.Label column={true}>VS Number</Form.Label>
                    </div>
                    <div className="col-sm-7">
                        <FormControl
                            className="input-wide"
                            id="VsNumber"
                            readOnly
                            type="text"
                            value={selectedProject && selectedProject.VsNumber ? selectedProject.VsNumber : ''}
                        />
                    </div>
                </div>
            </div>
            <div className="col-sm-4 zero-right-padding">
                <div className="row input-row">
                    <div className="col-sm-3 zero-side-padding">
                        <Form.Label column={true}>Start Date</Form.Label>
                    </div>
                    <div className="col-sm-7">
                        <FormControl
                            className="input-wide"
                            id="startDate"
                            readOnly
                            type="text"
                            value={selectedProject && selectedProject.startDate ? selectedProject.startDate : ''}
                        />
                    </div>
                    <div className="col-sm-1" />
                </div>

                <div className="row input-row">
                    <div className="col-sm-3 zero-side-padding">
                        <Form.Label column={true}>End Date</Form.Label>
                    </div>
                    <div className="col-sm-7">
                        <FormControl
                            className="input-wide"
                            id="endDate"
                            readOnly
                            type="text"
                            value={selectedProject && selectedProject.endDate ? selectedProject.endDate : ''}
                        />
                    </div>
                    <div className="col-sm-1" />
                </div>
            </div>
        </div>
    );
};

const mapStateToProps = (state: RootState): ProjectDetailsProps => ({
    selectedProject: state.project.selectedProject,
});

export default connect(mapStateToProps)(ProjectDetails);
