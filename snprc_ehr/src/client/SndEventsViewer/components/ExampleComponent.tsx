
import React from 'react'
import { InjectedQueryModels, withQueryModels, SchemaQuery, initQueryGridState, GridPanelWithModel, QueryConfig } from '@labkey/components'
import { createMemoryHistory, Route, Router, WithRouterProps } from 'react-router';


// First define the component you're going to wrap with withQueryModels
interface MyComponentProps {
    title: string;
}
// Here we create a type that includes InjectedQueryModels because we're wrapping the component with withQueryModels
// which will inject queryModels and actions objects.
type Props = MyComponentProps & InjectedQueryModels;
// Here we use the name ExampleComponentImpl, users will not use this component directly, only the wrapped version below
// which we expose to users as ExampleComponent.
class ExampleComponentImpl extends React.PureComponent<Props> {

    render() {
        initQueryGridState()

        const { actions, queryModels, title } = this.props;
        const model = queryModels.model;
        return (
            <div className="example-component">
                <div>{title}</div>
                <div>
                    {/* {model.isLoading && <LoadingSpinner />} */}
                    {/* {<span>The assay has {model.rowCount} runs</span>} */}
                </div>
                {/* <GridPanelWithModel
                        queryConfigs={queryConfigs}

                    /> */}
            </div>
        );
    }
}
// Next wrap your component with withQueryModels, here we set the type to MyComponentProps so the returned component,
// ExampleComponent, can be used in a type safe manner. In this case, if the user forgets to pass in a title we'll get
// a compiler error as intended.
export const ExampleComponent = withQueryModels<MyComponentProps>(ExampleComponentImpl);
// The component returned from withQueryModels, ExampleComponent in this case, now has the following props type:
// MyComponentProps & MakeQueryModels. To use the component you pass it a queryConfig and it will isntantiate the
// models you want and pass them to ExampleComponentImpl:

const queryConfigs = { model: { schemaQuery: SchemaQuery.create("study", "vitals") }};
// const queryConfigs = {
//     mixtures: {
//         bindURL: true,
//         schemaQuery: SchemaQuery.create("study", "vitals"),
//         urlPrefix: "mixtures",
//         maxRows: 10
//     }
// };
<ExampleComponent title="My Example Component" queryConfigs={queryConfigs} autoLoad />

// const history = createMemoryHistory();

// const ExampleGrid: React.FunctionComponent<WithRouterProps> = (props: WithRouterProps): React.ReactElement => {
//     const { location, router } = props;
//     const queryString = Object.keys(location.query)
//         .map(key => {
//             const value = location.query[key];
//             return key + '=' + value;
//         })
//         .join('&');
//     const queryConfigs: QueryConfig = {
//         bindURL: true,
//         schemaQuery: SchemaQuery.create('exp.data', 'mixturespaging'),
//         urlPrefix: 'mixtures',
//     };

//     const onQueryChange = (evt: ChangeEvent<HTMLInputElement>): void => {
//         const query = {};
//         evt.target.value.split('&').forEach(segment => {
//             const [ key, value ] = segment.split('=');
//             query[key] = value;
//             router.replace({...location, query });
//         });
//     };

//     return (
//         <div className="query-model-example">
//             <div>
//                 <label>URL Query Params: </label>
//                 <input style={{ width: '800px' }} value={queryString} onChange={onQueryChange} />
//             </div>
//             <GridPanelWithModel
//                 ButtonsComponent={GridPanelButtonsExample}
//                 title="Mixtures"
//                 queryConfig={queryConfigs}
//             />
//         </div>
//     );
// };

// return (
//     <Router history={history}>
//         <Route path="/" component={ExampleGrid} />
//     </Router>
// );
//})
