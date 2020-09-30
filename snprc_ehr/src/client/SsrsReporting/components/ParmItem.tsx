import React from "react";
import moment from "moment";
import { ReportParm } from "../services/reportParms";
import WrappedDatePicker from "../../Shared/components/WrappedDatePicker";

interface Props {
    parm: ReportParm;
}
interface State {
    value: string;
}

export class ParmItem extends React.Component<Props, State> {
    constructor(props: Props) {
        super(props);

        this.state = { value: "" };
    }

    componentDidMount = (): void => {
        this.setState(() => ({
            value: this.props.parm.value ? this.props.parm.value : "",
        }));
    };
    handleChange = (e: React.ChangeEvent<HTMLInputElement>): void => {
        const value = e.target.value;

        this.setState(() => ({
            value,
        }));
    };

    handleDateChange = (date: moment.Moment): void => {
        this.setState(() => ({
            value: moment(date).format("YYYY-MM-DD hh:mm:ss"),
        }));

        console.log("date: ", date);
    };

    render() {
        return (
            <>
                {this.props.parm.type.toLowerCase() === "string" && (
                    <label className="field-label">
                        {this.props.parm.label}
                        <input
                            type="text"
                            value={this.state.value}
                            onChange={this.handleChange}
                        />
                    </label>
                )}
                {this.props.parm.type.toLowerCase() === "number" && (
                    <label>
                        {this.props.parm.label}
                        <input
                            type="number"
                            value={this.state.value}
                            onChange={this.handleChange}
                        />
                    </label>
                )}
                {this.props.parm.type.toLowerCase() === "date" && (
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
