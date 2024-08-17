/* eslint-disable no-unused-vars */

import React from 'react'
import { shallow } from 'enzyme'
import SsrsReporting from '../SsrsReporting'

import { fetchReportList } from '../api/fetchReportList'
jest.mock('../api/fetchReportList')

require('setimmediate')

beforeAll(() => {
    // global.fetch = jest.fn();
})

let wrapper

beforeEach(() => {
    wrapper = shallow(<SsrsReporting />)
})

afterEach(() => {
    wrapper.unmount()
})

function flushPromises() {
    return new Promise(resolve => setImmediate(resolve))
}

describe('SsrsReporting tests', () => {

    test('Should render a loading spinner before rendering the landing page.', async () => {
        wrapper.unmount()
        wrapper = shallow(<SsrsReporting />, { disableLifecycleMethods: true })
        await flushPromises()
        expect(wrapper).toMatchSnapshot()
        expect(wrapper.find('LoadingSpinner').exists()).toBeTruthy()
    })

    test('Should render the landing page.', async () => {
        await flushPromises()
        expect(wrapper).toMatchSnapshot()

        // spinner should be gone
        expect(wrapper.find('LoadingSpinner').exists()).toBeFalsy()
        // ReportSelectionPanel and ReportParmsPanel should be present
        expect(wrapper.find('ReportSelectionPanel').exists()).toBeTruthy()
        expect(wrapper.find('ReportParmsPanel').exists()).toBeTruthy()
    })

})
