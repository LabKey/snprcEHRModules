import React from 'react';

const FORCE_RENDER = true;

class TimelineDetails extends React.Component {

    constructor(props) {
        super(props);
        this.state = { 
            value: '',
            selectedTimeline: (this.props.store.getState().project.selectedTimeline || null)
        };
        this.disconnect = this.props.store.subscribe(this.handleStoreUpdate);
    }

    componentWillUnmount = () => this.disconnect();

    handleStoreUpdate = () => {
        let selectedTimeline = this.props.store.getState().project.selectedTimeline || null;
        this.setState({ selectedTimeline: selectedTimeline });
    }

    render() {
        if (this.state.selectedTimeline != null || FORCE_RENDER) {
            return (
                    <div className='container-fluid details-frame' style={{textAlign: 'left'}}>
                        <div className='col-sm-4'>
                            <div className='row input-row'>
                                <div className='col-sm-4 zero-side-padding'><label>Project</label></div>
                                <div className='col-sm-7'><input type='text' className='input-wide' disabled/></div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-4 zero-side-padding'><label>Research Coordinator</label></div>
                                <div className='col-sm-7'><input type='text' className='input-wide'/></div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-4 zero-side-padding'><label>Lead Technitian</label></div>
                                <div className='col-sm-7'><input type='text' className='input-wide'/></div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-4  zero-side-padding'><label>Draft</label></div>
                                <div className='col-sm-6'><input type='checkbox'
                                                                 style={{width: '20px', height: '20px'}}/></div>
                            </div>
                        </div>
                        <div className='col-sm-4'>
                            <div className='row input-row'>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><label>Start</label></div>
                                    <div className='col-sm-8'><input type='date' className='input-wide'/></div>
                                </div>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><label>End</label></div>
                                    <div className='col-sm-8'><input type='date' className='input-wide'/></div>
                                </div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><label>Created</label></div>
                                    <div className='col-sm-8'><input type='date' className='input-wide'
                                                                     readOnly={true}/></div>
                                </div>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><label>Created By</label></div>
                                    <div className='col-sm-8'><input type='text' className='input-wide'
                                                                     readOnly={true}/></div>
                                </div>
                            </div>
                            <div className='row input-row'>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><label>Modified</label></div>
                                    <div className='col-sm-8'><input type='date' className='input-wide'
                                                                     readOnly={true}/></div>
                                </div>
                                <div className='col-sm-6'>
                                    <div className='col-sm-4 zero-side-padding'><label>Modified By</label></div>
                                    <div className='col-sm-8'><input type='text' className='input-wide'
                                                                     readOnly={true}/></div>
                                </div>
                            </div>

                        </div>
                        <div className='col-sm-4'>
                            <div className='row' style={{marginLeft: '20px'}}>
                                <div className='col-sm-4'><label>Study Notes</label></div>
                                <div className='col-sm-8 zero-side-padding'><textarea rows='3' cols='50'/></div>
                            </div>
                            <div className='row' style={{marginLeft: '20px'}}>
                                <div className='col-sm-4'><label>Scheduler Notes</label></div>
                                <div className='col-sm-8 zero-side-padding'><textarea rows='3' cols='50'/></div>
                            </div>
                        </div>
                    </div>
            )
        } else {
            return <div>Please select a timeline to view it's details</div>
        }

    }
}

export default TimelineDetails;