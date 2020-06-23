import React from 'react';
import Select from 'react-select';
import WrappedDatePicker from './WrappedDatePicker';
import InfoPanel from './InfoPanel';
import { validateCage } from '../services/validation';

export default class LocationPanel extends React.Component {

    state = {
        errorMessage: undefined
    }

    componentDidMount = () => {
        this.props.preventNext(); //prevent/Allow Next button
    }

    handleCageChange = e => {
        const cage = e.target.value;
        const { room } = this.props.newAnimalData;

        const errorMessage = validateCage(room, cage);
        if (errorMessage === undefined) {
            this.props.handleDataChange('cage', { value: cage });
        }
        
        this.setState((prevState) => (
            {
                ...prevState,
                errorMessage: errorMessage
            }
        ));
    }

    handleRoomChange = room => {
        const el = document.getElementById("cage-input");
        if (room.maxCages) {
            el.disabled = false;
            el.value = null;
            el.max = room.maxCages;
        }
        else {
            el.disabled = true;
            el.value = null;
        }
        this.props.handleDataChange('room',room);
        this.props.handleDataChange('cage', { value: undefined });
    }

    handleDateSelect = date => {
        //do nothing
    }
    handleDateChangeRaw = e => {
        e.preventDefault();
    }

    isInteger = e => {
        const i = e.key    //which ? e.which : e.keyCode;
        console.log(i);
        const isInteger = (i >= 0 && i <= 9);
        if (!isInteger) {
            e.preventDefault();
        }

        return isInteger;
    }

    handlePaste = e => {
        e.preventDefault();
    }

    render() {
        let { room, cage, acqDate } = this.props.newAnimalData;
        return (
            <>
                <div className="wizard-panel__rows">
                    <div className="wizard-panel__row" >
                        <div className="wizard-panel__col">
                            <div className="location-datepicker">
                                <WrappedDatePicker
                                    label="Move Date Time"
                                    todayButton="Today"
                                    dateFormat="Pp"
                                    selected={acqDate.date.toDate()}
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
                                isLoading={this.props.locationList.length === 0}
                                id="location-select"
                                autoFocus
                            />
                        </div>
                    </div>
                    <div className="wizard-panel__row" >
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
                                onPasteCapture={this.handlePaste}

                            />
                        </div>
                    </div>
                </div>
                <InfoPanel
                    messages={
                        [{ propTest: !room, colName: "Location" }]
                    }
                    errorMessages={
                        [{ propTest: this.state.errorMessage, colName: this.state.errorMessage }]
                    }

                />
            </>
        )
    }
}
