import React from "react";
import {
    GridPanelWithModel,
    SchemaQuery,
    ManageDropdownButton,
    RequiresModelAndActions,
    QueryConfig,
} from "@labkey/components";
import { MenuItem, Panel } from "react-bootstrap";
import { WithRouterProps } from "react-router";

class SndGridPanelButtons extends React.PureComponent<RequiresModelAndActions> {
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

const SndEventsPanel: React.FunctionComponent<WithRouterProps> = (
    props: WithRouterProps
): React.ReactElement => {

    const queryConfigs: QueryConfig = {
        schemaQuery: SchemaQuery.create("snd", "Events"),
    };

    return (
        <>
            <Panel>
                <Panel.Heading>
                   <div className={"panel-title"}>{"Snd Events"}</div>
                </Panel.Heading>
                <Panel.Body>
                    <GridPanelWithModel
                        ButtonsComponent={SndGridPanelButtons}
                        title="Animal Events"
                        queryConfig={queryConfigs}
                        asPanel={false}
                        allowSelections={true}
                        showChartMenu={false}
                    />
                </Panel.Body>
            </Panel>
        </>
    );
};

export default SndEventsPanel;
