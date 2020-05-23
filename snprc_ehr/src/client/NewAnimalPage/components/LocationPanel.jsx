import React from 'react';
import Select from 'react-select';
import WrappedDatePicker from '../../utils/components/WrappedDatePicker';

export default class LocationPanel extends React.Component {

    state = {
        errorMessage: undefined
    };

    componentDidMount = () => {
        this.props.preventNext(!this.props.newAnimalData.room); //prevent/Allow Next button
    }
    handleCageChange = e => {
        const value = e.target.value;
        const validatedOption = this.validate('cage', { value });
        if (!validatedOption.hasError) {
            this.props.handleDataChange('cage', validatedOption);
        }
        
    }

    handleRoomChange = room => {
        const el = document.getElementById("cage-input");
        if (room.maxCages) {
            el.disabled = false
            el.value = null;
            el.max = room.maxCages;
        }
        else {
            el.disabled = true;
            el.value = null
        }
        this.props.handleDataChange('room', this.validate('room', room));
        this.props.handleDataChange('cage', {value: null, hasError: false} );
        this.props.preventNext(false); //prevent/Allow Next button
    }

    validate = (property, option) => {
        switch (property) {
            case 'cage':
                const { room } = this.props.newAnimalData;
                let hasError = false;
                if (room && room.maxCages) {
                   
                    hasError = option.value !== ""  && (option.value > room.maxCages || option.value < 1);

                    const errorMessage = hasError ? `Cage # must be between 1 and ${room.maxCages} in ${room.value}` : undefined;

                    this.setState((prevState) => (
                        {
                            ...prevState,
                            errorMessage: errorMessage
                        }
                    ));
                }

                this.props.handleError(hasError);
                return ({
                    ...option,
                    hasError
                })
                

            case 'room':
                // TODO: what constitutes a room error?
                return ({
                    ...option,
                    hasError: false
                })
        }
    }
    handleDateSelect = date => {
        //do nothing
    };
    handleDateChangeRaw = e => {
        e.preventDefault();
    }
    isInteger = e => {
        const i = e.key    //which ? e.which : e.keyCode;
        console.log(i);
        const isInteger =  (i >= 0 && i <= 9);
        if (!isInteger) {
            e.preventDefault();
        }

        return isInteger;
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
                                selected={acqDate.date}
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
                            defaultValue={room}
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
                        <input type="number" 
                            onKeyPress={this.isInteger}
                            id="cage-input"
                            className="cage-input"
                            placeholder="Cage #"
                            min="1"
                            max={room ? room.maxCages : 1}
                            defaultValue={cage.value}
                            onChange={this.handleCageChange}
                            disabled={!(room && room.maxCages)}

                        />
                    </div>
                </div>
                <div className="wizard-panel__row" >
                    <div className="err-panel">
                        {!room && 'You must select a location.'}
                        {this.state.errorMessage && this.state.errorMessage}
                    </div>
                </div>
            </div>

        )
    }
}
