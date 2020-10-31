/* eslint-disable no-alert */

import React from "react";
import { LoadingSpinner } from "../Shared/components/LoadingSpinner";
import "./styles/ssrsReporting.scss";
import { Button } from "react-bootstrap";
import ReportSelectionPanel from "./components/ReportSelectionPanel";
import InfoPanel from "../Shared/components/InfoPanel";
import { OptionsType } from "react-select";
import { ReportItem } from "./api/ReportItem";
import { fetchReportList } from "./api/fetchReportList";
import ReportParmsPanel from "./components/ReportParmsPanel";
import {
    ReportParm,
    parseParms,
    parmsToQueryString,
} from "./services/parmUtils";
import { printToPDF } from "./services/printToPDF";

interface State {
    reportList: OptionsType<ReportItem>;
    selectedReport?: ReportItem;
    errorMessage: string;
    isLoading: boolean;
    reportParameters?: ReportParm[];
    parms: string;
}
interface Props {}

export default class SsrsReporting extends React.Component<Props, State> {
    constructor(props: Props) {
        super(props);

        this.state = {
            reportList: [],
            errorMessage: "",
            isLoading: true,
            parms: "",
        };
    }

    componentDidMount = async () => {
        await fetchReportList()
            .then((response: ReportItem[]) => {
                this.setState({ reportList: response, isLoading: false });
            })
            .catch((error) => {
                this.setState(() => ({
                    errorMessage: error.exception,
                    isLoading: false
                }));
            });
    };

    //quit
    onQuitClick = (): void => {
        window.history.back();
    };

    onClickPrint = () => {
        if (!this.state.selectedReport) {
            this.setState(() => ({
                errorMessage: "Select a report before clicking print.",
            }));
        } else {
            printToPDF(this.state.selectedReport, this.state.parms);
            this.setState(() => ({
                errorMessage: "",
            }));
        }
    };

    handleChange = (selectedReport: ReportItem) => {
        const parsedParms = parseParms(selectedReport.parameters);

        this.setState(
            () => ({
                errorMessage: "",
                selectedReport: selectedReport,
                reportParameters: parsedParms,
                parms: "",
            }),
            () => {}
        );
    };

    handleParmChange = (index: number, parmItem: ReportParm): void => {
        let parameters: ReportParm[] = [...this.state.reportParameters];

        parameters.splice(index, 1, parmItem);

        this.setState(() => ({
            reportParameters: parameters,
            parms: parmsToQueryString(parameters),
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
                        <p>Report Description and Parameters</p>
                    </div>
                    <div className="wizard-panel">
                        <ReportParmsPanel
                            reportParameters={this.state.reportParameters}
                            handleParmChange={this.handleParmChange}
                            selectedReport={this.state.selectedReport}
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
