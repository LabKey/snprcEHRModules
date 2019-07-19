import React from 'react';
import { HashRouter, Route, Switch, Redirect } from 'react-router-dom';
import ProjectsView from '../views/ProjectsView';

class UIRouter extends React.Component {
        constructor(props) {
        super(props);
        this.state = { }
    }
    
    render() {
        return <HashRouter>
            <div>
                <Switch>
                    <Route path='/' exact render={() => (<ProjectsView store={this.props.store} />)} />
                    <Redirect to='/' />
                </Switch>
            </div>
        </HashRouter> 
    }
  }

  export default UIRouter;