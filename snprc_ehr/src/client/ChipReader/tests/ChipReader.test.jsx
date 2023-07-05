/* eslint-disable no-unused-vars */

import React from 'react'
import { shallow } from 'enzyme'
import ChipReader from '../ChipReader'

require("setimmediate")

jest.mock('../../Shared/api/api')

beforeAll(() => {
    // global.fetch = jest.fn();
})

let wrapper

beforeEach(() => {
    wrapper = shallow(<ChipReader debug />)
})

afterEach(() => {
    wrapper.unmount()
})

function flushPromises() {
    return new Promise(resolve => setImmediate(resolve))
}

describe('ChipReader tests', () => {
    test('Should render the landing page with no serial support error.', async () => {
        wrapper = shallow(<ChipReader />)
        await flushPromises()
        expect(wrapper).toMatchSnapshot()
    })

    test('Should render the landing page without error message.', async () => {
        await flushPromises()
        expect(wrapper).toMatchSnapshot()

        // spinner should be gone
        expect(wrapper.find('LoadingSpinner').exists()).toBeFalsy()
        // ChipDataPanel and SummaryGridPanel panels should be present
        expect(wrapper.find('ChipDataPanel').exists()).toBeTruthy()
        expect(wrapper.find('SummaryGridPanel').exists()).toBeTruthy()
    })

    test('Should render a loading spinner before rendering the landing page.', async () => {
        wrapper.unmount()
        wrapper = shallow(<ChipReader />, { disableLifecycleMethods: true })
        await flushPromises()
        expect(wrapper).toMatchSnapshot()
        expect(wrapper.find('LoadingSpinner').exists()).toBeTruthy()
    })
})
