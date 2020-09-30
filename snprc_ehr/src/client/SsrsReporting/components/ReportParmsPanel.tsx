import React, { FormEvent } from "react";
import { ParmItem } from "./ParmItem";
import { ReportParm } from "../services/reportParms";

interface Props {
    reportParameters: Array<ReportParm>;
    handleReportParameters(reportParms: Array<ReportParm>): void;
}
interface State {
    value: string;
}
export default class ReportParmsPanel extends React.Component<Props, State> {
  constructor(props) {
    super(props);
    this.state = {
      value: '' 
    }

  }
  handleChange = (option: string): void => {

    this.setState(() => ({
        value: option
    }));
  };

    

    handleSubmit = (e: React.FormEvent<HTMLFormElement>): void => {
        console.log("A name was submitted");
        e.preventDefault();
    };

    render() {
        return (
            <form onSubmit={this.handleSubmit}>
                <div className="wizard-panel-col">
                    {this.props.reportParameters &&
                        this.props.reportParameters.map(
                            (parm, index: number) => {
                                return <ParmItem 
                                  parm={parm} 
                                  key={index}
                                />;
                            }
                    )}
                    { this.props.reportParameters && this.props.reportParameters.length === 0 &&
                    <div style= {{padding: "1rem"}}>Report doesn't require parameters</div>}
                </div>
            </form>
        );
    }
}
