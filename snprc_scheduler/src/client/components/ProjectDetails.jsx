import React from 'react';
import connect from "react-redux/es/connect/connect";

class ProjectDetails extends React.Component {

    render() {
        if (this.props.selectedProject != null) {
            return (<div className='container-fluid details-frame' style={{textAlign: 'left'}}>
                <div className='row input-row'>
                    <div className='col-sm-4'>
                        <div className='row input-row'>
                            <div className='col-sm-4'><label>Cost Account</label></div>
                            <div className='col-sm-6'><input type='text' className='input-wide' readOnly
                                                             value={this.props.selectedProject.CostAccount || ''}/>
                            </div>
                        </div>
                        <div className='row input-row'>
                            <div className='col-sm-4'><label>Charge ID</label></div>
                            <div className='col-sm-6'><input type='text' className='input-wide' readOnly
                                                             value={this.props.selectedProject.referenceId || ''}/>
                            </div>
                        </div>
                        <div className='row input-row'>
                            <div className='col-sm-4'><label>IACUC</label></div>
                            <div className='col-sm-6'><input type='text' className='input-wide' readOnly
                                                             value={this.props.selectedProject.Iacuc || ''}/></div>
                        </div>
                    </div>
                    <div className='col-sm-4'>
                        <div className='row input-row'>
                            <div className='col-sm-4'><label>Primary Vet</label></div>
                            <div className='col-sm-6'><input type='text' className='input-wide' readOnly
                                                             value={this.props.selectedProject.Veterinarian1 || ''}/>
                            </div>
                        </div>

                        <div className='row input-row'>
                            <div className='col-sm-4'><label>Secondary Vet</label></div>
                            <div className='col-sm-6'><input type='text' className='input-wide' readOnly
                                                             value={this.props.selectedProject.Veterinarian2 || ''}/>
                            </div>
                        </div>

                        <div className='row input-row'>
                            <div className='col-sm-4'><label>VS Number</label></div>
                            <div className='col-sm-6'><input type='text' className='input-wide' readOnly
                                                             value={this.props.selectedProject.VsNumber || ''}/></div>
                        </div>
                    </div>
                    <div className='col-sm-4'>
                        <div className='row input-row'>
                            <div className='col-sm-4'><label>Start Date</label></div>
                            <div className='col-sm-6'><input type='text' className='input-wide' readOnly
                                                             value={this.props.selectedProject.startDate || ''}/></div>
                        </div>

                        <div className='row input-row'>
                            <div className='col-sm-4'><label>End Date</label></div>
                            <div className='col-sm-6'><input type='text' className='input-wide' readOnly
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