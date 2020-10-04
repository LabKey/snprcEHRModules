import React from "react";
import moment from "moment";
import { ReportParm } from "../services/parmUtils";
import WrappedDatePicker from "../../Shared/components/WrappedDatePicker";

interface Props {
    parm: ReportParm;
    index: number;
    handleParmChange(index:number, parmItem: ReportParm): void;
}

interface State {
    value: string;
    parmItem: ReportParm;
    index: number;
    dateFormat?: string;
}

export class ParmItem extends React.Component<Props, State> {
    constructor(props: Props) {
        super(props);

        this.state = { 
            value: "",
            parmItem: this.props.parm,
            index: this.props.index,
            dateFormat: (this.props.parm.type.includes('date') && this.props.parm.type === 'date') ? "YYYY-MM-DD" : "YYYY-MM-DD hh:mm:ss" 
        };
    }
    
    componentDidMount = (): void => {
        let value = '';
    
        if (this.props.parm.type.includes('date') )
        {
            value = this.props.parm.value === '' ? moment().format(this.state.dateFormat) : moment(this.props.parm.value).format(this.state.dateFormat)
        }
        else
        {
            value = this.props.parm.value === '' ? '' : this.props.parm.value
        }
        this.handleChange(value)
        
    };

    handleElementChange =  (e: React.ChangeEvent<HTMLInputElement>): void => {
        const value = e.target.value;

        this.handleChange (value);
    };

    handleDateChange = (date: moment.Moment): void => {

        const value = moment(date).format(this.state.dateFormat);

        this.handleChange(value);
    };
     
    handleChange = (value: string): void  => {
        this.setState( prevState => ({
            value,
            parmItem: {
                    ...prevState.parmItem,
                    value
            }
        }), () => {
            this.props.handleParmChange(this.state.index, this.state.parmItem);
        });
    };

    render() {
        return (
            <>
                {this.props.parm.type.toLowerCase() === "string" && (
                    <label className="field-label">
                        {this.props.parm.label}
                        <input
                            className="form-input"
                            type="text"
                            value={this.state.value}
                            onChange={this.handleElementChange}
                        />
                    </label>
                )}
                {this.props.parm.type.toLowerCase() === "number" && (
                    <label>
                        {this.props.parm.label}
                        <input
                            className="form-input"
                            type="number"
                            value={this.state.value}
                            onChange={this.handleElementChange}
                        />
                    </label>
                )}
                {this.props.parm.type.toLowerCase() === "date" && (
                    <div>
                        <label className="field-label-align-close">
                            {this.props.parm.label}
                        </label>
                        <WrappedDatePicker
                            dateFormat="P"
                            id="form-datepicker"
                            maxDate={moment().toDate()}
                            onChange={this.handleDateChange}
                            onSelect={this.handleDateChange}
                            selected={ 
                                    this.state.value === ""
                                     ? moment().toDate()
                                     : moment(this.state.value).toDate()
                            }
                            todayButton="Today"
                        />
                    </div>
                )}
                {this.props.parm.type.toLowerCase() === "datetime" && (
                    <div>
                        <label className="field-label-align-close">
                            {this.props.parm.label}
                        </label>
                        <WrappedDatePicker
                            dateFormat="Pp"
                            id="form-datepicker"
                            maxDate={moment().toDate()}
                            onChange={this.handleDateChange}
                            onSelect={this.handleDateChange}
                            selected={ 
                                    this.state.value === ""
                                     ? moment().toDate()
                                     : moment(this.state.value).toDate()
                            }
                            showTimeSelect
                            timeFormat="p"
                            timeIntervals={30}
                            todayButton="Today"
                        />
                    </div>
                )}
            </>
        );
    }
}



