import React, { FC } from 'react';
import { HashRouter, Route, Switch, Redirect } from 'react-router-dom';
import ProjectsView from '../views/ProjectsView';

interface Props {
    store: any;
}

export const UIRouter: FC<Props> = ({ store }) => (
    <HashRouter>
        <div>
            <Switch>
                <Route path='/' exact render={() => <ProjectsView store={store} />} />
                <Redirect to='/' />
            </Switch>
        </div>
    </HashRouter>
);
