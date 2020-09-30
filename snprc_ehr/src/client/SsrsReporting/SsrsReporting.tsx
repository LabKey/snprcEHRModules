/* eslint-disable no-alert */

import React from "react";
import { LoadingSpinner } from "../Shared/components/LoadingSpinner";
import "./styles/ssrsReporting.scss";
import { Button } from "react-bootstrap";
import ReportSelectionPanel from "./components/ReportSelectionPanel";
import { getReportPath } from "./services/printToPDF";
import InfoPanel from "../Shared/components/InfoPanel";
import { OptionsType } from "react-select";
import { reportList, ReportType } from "./api/ReportList";
import ReportParmsPanel from "./components/ReportParmsPanel";
import { ReportParm, parseParms } from "./services/reportParms";

interface State {
    reportList: OptionsType<ReportType>;
    selectedReport?: ReportType;
    errorMessage: string;
    isLoading: boolean;
    reportParameters?: Array<ReportParm>;
    parms: string;
}
interface Props {}

export default class SsrsReporting extends React.Component<Props, State> {
    constructor(props: Props) {
        super(props);

        this.state = {
            reportList: [],
            // reportParameters: [{ name: "", type: "", label: "", value: "" }],
            errorMessage: "",
            isLoading: true,
            parms: "",
        };
    }

    componentDidMount = () => {
        this.setState({ reportList, isLoading: false });
    };

    //quit
    onQuitClick = (): void => {
        window.history.back();
    };

    onClickPrint() {
        if (!this.state.selectedReport) {
            this.setState(() => ({
                errorMessage: "Select a report before clicking print.",
            }));
        } else {
            const reportPath = getReportPath(
                this.state.selectedReport.value
            );

            const fullPath = `${reportPath}${this.state.parms}`;
            const left = window.screenX + 20;
            window.open(
                fullPath,
                "_blank",
                `location=yes,height=850,width=768,status=yes, left=${left}`
            );

            this.setState(() => ({
                errorMessage: "",
            }));
        }
    }

    handleChange = (selectedReport: ReportType) => {
        this.setState(
            () => ({
                errorMessage: "",
                selectedReport: selectedReport,
                reportParameters: parseParms(selectedReport.parameters),
            }),
            () => {
                console.log('ssrsReporting', this.state.selectedReport);
            }
        );
    };
    handleReportParameters = (value: Array<ReportParm>): void => {
        this.setState(() => ({
            reportParameters: value,
        }));
    };

    render() {
        const { isLoading } = this.state;

        if (isLoading) {
            return <LoadingSpinner msg="Loading app..." />;
        }

        return (
            <div>
                <div className="parent-panel">
                    <div className="report-div">
                        <ReportSelectionPanel
                            reportList={this.state.reportList}
                            handleChange={this.handleChange}
                            selectedReport={this.state.selectedReport}
                        />
                    </div>
                    <div className="panel-heading">
                        <p>Report Parameters</p>
                    </div>
                    <div className="wizard-panel">
                        <ReportParmsPanel
                            reportParameters={this.state.reportParameters}
                            handleReportParameters={this.handleReportParameters}
                        />
                    </div>
                    <InfoPanel
                        errorMessages={
                            this.state.errorMessage && [
                                {
                                    propTest: true,
                                    colName: this.state.errorMessage,
                                },
                            ]
                        }
                        infoMessages={[
                            {
                                key: 1,
                                value:
                                    "Select a report, enter parameters, and then press the print button",
                            },
                        ]}
                    />
                </div>

                <div className="wizard-footer">
                    <Button bsStyle="primary" onClick={this.onClickPrint}>
                        Print Report{" "}
                        <i aria-hidden="true" className="fa fa-print" />
                    </Button>
                    <Button onClick={this.onQuitClick}>Quit</Button>
                </div>
            </div>
        );
    }
}
