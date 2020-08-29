/* eslint-disable no-alert */

import React from 'react'
import { LoadingSpinner } from '@labkey/components'
import './styles/sndEventsViewer.scss'
import SndEventState from './constants/sndEventsState'
import constants from './constants/index'
import SndEventsPanel from './components/SndEventsPanel'
import { Route, Router, createMemoryHistory } from 'react-router'

export default class SndEventsViewer extends React.Component {
    state = new SndEventState();

    debug = constants.debug;

    componentDidMount() {
        // prevent user from navigating away from page
        window.addEventListener('beforeunload', this.beforeunload.bind(this))
        this.setState(prevState => (
            {
                ...prevState,
                isLoading: false
            }
        ))
    }

    componentWillUnmount() {
        window.removeEventListener('beforeunload', this.beforeunload.bind(this))
    }

    beforeunload(e) {
        if (this.state.isDirty) {
            e.preventDefault()
            e.returnValue = true
        }
    }

    handleError = value => {
        this.setState(prevState => (
            {
                ...prevState,
                hasError: value
            }
        ))
    }

    render() {
        // allow debug mode to be triggered for running test suite
        this.debug = this.props.debug !== undefined ? this.props.debug : constants.debug

        const { isLoading } = this.state

        if (isLoading) {
            return (
                <LoadingSpinner msg="Loading page..." />
            )
        }

        return (
            <Router history={createMemoryHistory()}>
                <div className="parent-panel">
                    <Route path="/" component={ SndEventsPanel } />
                </div>
            </Router>
        )
    }
}
