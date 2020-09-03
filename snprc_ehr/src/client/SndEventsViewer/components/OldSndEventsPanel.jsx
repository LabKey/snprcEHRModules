import React from "react";
import { GridPanelWithModel, SchemaQuery, ManageDropdownButton, initQueryGridState, RequiresModelAndActions } from "@labkey/components";
import { MenuItem, Panel } from "react-bootstrap";
import "@labkey/components/dist/components.css";

class GridPanelButtonsExample extends React.PureComponent<RequiresModelAndActions> {
    render() {
        return (
            <ManageDropdownButton id="eventsbtn">
                <MenuItem onClick={() => console.log("Menu Item 1 Clicked")}>
                    Do Something
                </MenuItem>
                <MenuItem onClick={() => console.log("Menu Item 2 Clicked")}>
                    Do Something Else
                </MenuItem>
            </ManageDropdownButton>
        );
    }
}

export default class SndEventsPanel extends React.Component {

    constructor(props) {
        super(props)

        initQueryGridState()

        this.state = {
            errorMessage: undefined,
            schemaName: undefined,
            queryName: undefined,
        }
    }


    componentDidMount = () => {
        console.log("SndEventsPanel mounted");
    };

    render() {
        const queryConfigs = {
            mixtures: {
                bindURL: true,
                schemaQuery: SchemaQuery.create("study", "vitals"),
                urlPrefix: "mixtures",
                maxRows: 10
            }
        };

        return (
            <>
                <Panel>
                    <Panel.Heading>
                        <div className={"panel-title"}>{'Vitals'}</div>
                    </Panel.Heading>
                    <Panel.Body>
                    <GridPanelWithModel
                        ButtonsComponent={GridPanelButtonsExample}
                        title="Animal Events"
                        queryConfigs={queryConfigs}
                        asPanel={true}
                        showOmniBox={true}
                        allowSelections={true}
                        showChartMenu={true}
                    />
                    </Panel.Body>
                </Panel>
            </>
        );
    }
}
