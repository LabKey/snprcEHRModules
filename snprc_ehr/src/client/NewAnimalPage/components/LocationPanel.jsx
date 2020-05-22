import React from 'react';
import Select from 'react-select';
import WrappedDatePicker from '../../utils/components/WrappedDatePicker';

export default class LocationPanel extends React.Component {

    state =  {
        cageError: undefined,
        roomError: undefined
    };

    handleCageChange = e => {
        const option = e.target.value;
        this.validateDataItem('cage', option);
        this.props.handleDataChange('cage', option);
    } 
    handleRoomChange = room => {
        const el = document.getElementById("cage-input");
        if (room.maxCages) {
            el.disabled = false
            el.value = null;
            el.max = room.maxCages;
            this.props.handleDataChange('cage', null);
        }
        else {
            el.disabled = true;
            el.value = null
            this.props.handleDataChange('cage', null);
        }

        this.props.handleDataChange('room', room);
    }

    validateDataItem = (property, value) => {
        if (!property || !value) return (undefined);
        switch (property) {
            case 'cage':
                const error = (value > this.props.newAnimalData.room.maxCages) ?
                    `The maximum number of cages allowed in ${this.props.newAnimalData.room.value} is ${this.props.newAnimalData.room.maxCages}` :
                    undefined;

                this.setState( (prevState) => (
                    {   
                        ...prevState,
                        cageError: error
                    }
                ));
                this.props.handleError(this.state.cageError===undefined);
                break;
            case 'room':
                if ( true ) {  // TODO: what constitutes a room error?
                    const error = 'Room error occured';
                    this.setState( (prevState) => (
                        {   
                            ...prevState,
                            roomError: error
                        }
                    ));
                }
                break;
        }
    }


    handleDateSelect = date => {
        //do nothing
    };
    handleDateChangeRaw = e => {
        e.preventDefault();
      }
    render() {
        let { room, cage, acqDate } = this.props.newAnimalData;
        return (
            <div className="wizard-panel__rows">
                <div className="wizard-panel__row" >
                    <div className="wizard-panel__col">
                        <div className="location-datepicker">
                            <WrappedDatePicker
                                label="Move Date Time"
                                todayButton="Today"
                                dateFormat="Pp"
                                selected={ acqDate }
                                onSelect={this.handleDateSelect}
                                onChange={this.handleDateSelect}
                                onChangeRaw={this.handleDateChangeRaw}
                                readOnly={true}
                                disabledKeyboardNavigation={true}
                                disabled={this.props.disabled}
                            />
                        </div>
                    </div>
                </div>
                <div className="wizard-panel__row" >
                    <div className="wizard-panel__col">
                        <label className="field-label" >Location</label>
                        <Select 
                                defaultValue= {room}
                                className="shared-dropdown"
                                classNamePrefix="shared-select"
                                options={this.props.locationList}
                                onChange={this.handleRoomChange}
                                placeholder="Select Location"
                                isDisabled={this.props.disabled}
                                id="location-select"
                        />
                    </div>
                    <div className="wizard-panel__col">
                        <label className="field-label" >Cage</label>
                        <input type="number" id="cage-input"
                            className="cage-input"
                            placeholder="Cage #"
                            min="1"
                            max={room ? room.maxCages : 1}
                            defaultValue={ cage }
                            onChange={this.handleCageChange}
                            disabled={ !cage }
                        />
                    </div>
                </div>
                <div className="wizard-panel__row" >
                    <div className="err-panel">
                        {this.state.cageError && this.state.cageError}
                        {this.state.roomError && this.state.roomError}
                    </div>
                </div>
            </div>
            
        )
    }
}
