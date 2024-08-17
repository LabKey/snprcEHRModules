/* eslint-disable no-unused-vars */

import React from 'react'
import { shallow } from 'enzyme'
import Select from 'react-select'
import BirthRecordReport from '../BirthRecordReport'
import { request } from '../../Shared/api/api'
import data from './fixtures/testData'

require("setimmediate")

jest.mock('../../Shared/api/api')

let wrapper

beforeEach(() => {
    wrapper = shallow(<BirthRecordReport />)
})

afterEach(() => {
    wrapper.unmount()
})

function flushPromises() {
    return new Promise(resolve => setImmediate(resolve))
}

describe('BirthRecordReport tests', () => {
    test('Should render a loading spinner    before api calls.', () => {
        wrapper = shallow(<BirthRecordReport />, { disableLifecycleMethods: true })
        expect(wrapper).toMatchSnapshot()
        expect(wrapper.find('LoadingSpinner').exists()).toBeTruthy()
    })

    test('Should render AnimalSelectionPanel.', async () => {
        await flushPromises()

        // spinner should be gone
        expect(wrapper.find('LoadingSpinner').exists()).toBeFalsy()

        // AnimalSelection panels should be present
        expect(wrapper.find('AnimalSelectionPanel').exists()).toBeTruthy()

        // InfoPanel should be present
        wrapper.find('AnimalSelectionPanel').dive().find('InfoPanel')

        // componentDidMount should have loaded lists for dropdowns
        expect(wrapper.state('animalList').length).toBe(2)

        // snapshot test (full page render after lists have been loaded)
        expect(wrapper).toMatchSnapshot()
    })

    test('Should render selected Animal.', async () => {
        await flushPromises()

        const animalSelectionPanel = wrapper.find('AnimalSelectionPanel')

        // Animal Select
        const animalSelect = animalSelectionPanel.dive().find(Select)

        // Test Animal Change
        animalSelect.simulate('change', data.animal)
        await flushPromises()
        expect(wrapper.state().selectedAnimal).toEqual(data.animal)

        // snapshot test (full page render after lists have been loaded)
        expect(wrapper).toMatchSnapshot()
    })
})
