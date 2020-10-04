import React from "react";
import { ParmItem } from "./ParmItem";
import { ReportParm } from "../services/parmUtils";
import { ReportItem } from "../api/ReportItem"

interface Props {
  reportParameters: ReportParm[];
  handleParmChange(index: number, parmItem: ReportParm): void;
  selectedReport: ReportItem;
}
export default class ReportParmsPanel extends React.Component<Props, {}> {

  handleParmChange = (index:number, parmItem: ReportParm): void => {
    this.props.handleParmChange(index, parmItem);
  };

  render() {
    return (
      <>
        <div className="wizard-panel-col">
        {this.props.selectedReport &&
          <div className="info-text-span"> {this.props.selectedReport.description} </div>
        }
          {this.props.reportParameters &&
           this.props.reportParameters.map(
              (parm, index) => {
                return <ParmItem 
                  parm={parm} 
                  index={index}
                  key={this.props.selectedReport.value+parm.name} 
                  handleParmChange = {this.handleParmChange}
                  />;
              }
           )}
          {this.props.reportParameters &&
            this.props.reportParameters.length === 0 && (
              <div style={{ padding: "1rem" }}>
                Report doesn't require parameters
              </div>
            )}
        </div>
      </>
    );
  }
}
