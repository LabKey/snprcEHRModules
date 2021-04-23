/* eslint-disable no-unused-vars */

import React from 'react'
import { shallow } from 'enzyme'
import Select from 'react-select'
import moment from 'moment'
import NewAnimalPage from '../NewAnimalPage'
import { request } from '../../Shared/api/api'
import data from './fixtures/testData'

jest.mock('../../Shared/api/api')

beforeAll(() => {
    // global.fetch = jest.fn();
})

let wrapper

beforeEach(() => {
    wrapper = shallow(<NewAnimalPage debug />)
})

afterEach(() => {
    wrapper.unmount()
})

function flushPromises() {
    return new Promise(resolve => setImmediate(resolve))
}

const setupInitialPage = async shallowWrapper => {
    await flushPromises()

    // select acquisition type
    const speciesPanel = shallowWrapper.find('SpeciesPanel')
    speciesPanel.dive().find('Radio').at(0).simulate('change', {
        target: data.selectedOption
    })

    // Species Select
    const speciesSelect = speciesPanel.dive().find(Select)
    speciesSelect.simulate('change', data.species)

    // Set Acquisition Date
    const acquisitionPanel = wrapper.find('AcquisitionPanel')
    const acquisitionDatePicker = acquisitionPanel.dive().find('WrappedDatePicker')
    acquisitionDatePicker.simulate('select', data.acquisitionDate)

    await flushPromises()
}

const pageNext = async (shallowWrapper, numPages = 1) => {
    const pagerItem = shallowWrapper.find('PagerItem').at(1)

    for (let i = 0; i < numPages; i++) { pagerItem.simulate('click') }

    await flushPromises()
}

describe('NewAnimalPage tests', () => {
    test('Should render a loading spinner    before api calls.', () => {
        wrapper = shallow(<NewAnimalPage debug />, { disableLifecycleMethods: true })
        expect(wrapper).toMatchSnapshot()
        expect(wrapper.find('LoadingSpinner').exists()).toBeTruthy()
    })

    test('Should render Species/Acquisition page after lists are loaded.', async () => {
        await flushPromises()

        // spinner should be gone
        expect(wrapper.find('LoadingSpinner').exists()).toBeFalsy()

        // species and acquisition panels should be present
        expect(wrapper.find('SpeciesPanel').exists()).toBeTruthy()
        expect(wrapper.find('AcquisitionPanel').exists()).toBeTruthy()

        // Modals should be present
        expect(wrapper.find('CancelChangeModal').at(0).exists()).toBeTruthy()
        expect(wrapper.find('CancelChangeModal').at(1).exists()).toBeTruthy()
        expect(wrapper.find('SaveModal').exists()).toBeTruthy()

        // InfoPanel should be present
        wrapper.find('AcquisitionPanel').dive().find('InfoPanel')

        // Pager & PagerItems should be present
        expect(wrapper.find('Pager').exists()).toBeTruthy()
        expect(wrapper.find('PagerItem').at(0).exists()).toBeTruthy() // Previous page
        expect(wrapper.find('PagerItem').at(1).exists()).toBeTruthy() // Next page
        expect(wrapper.find('PagerItem').at(2).exists()).toBeTruthy() // Cancel Button

        // componentDidMount should have loaded lists for dropdowns
        expect(wrapper.state('speciesList').length).toBe(3)
        expect(wrapper.state('accountList').length).toBe(3)
        expect(wrapper.state('institutionList').length).toBe(3)
        expect(wrapper.state('dietList').length).toBe(3)

        // snapshot test (full page render after lists have been loaded)
        expect(wrapper).toMatchSnapshot()

        // Make sure birth change updates state correctly
        // Species Radio (acquisition type)
        const value = 'Birth'
        const speciesPanel = wrapper.find('SpeciesPanel')
        speciesPanel.dive().find('Radio').at(0).simulate('change', {
            target: { value }
        })
        await flushPromises()
        expect(wrapper.state('selectedOption')).toBe(value)
        expect(wrapper.state('acquisitionTypeList').length).toBe(3) // three items in the test data

        // Species Select
        const speciesSelect = speciesPanel.dive().find(Select)

        // Test species change & Select component
        speciesSelect.simulate('change', data.species)
        await flushPromises()
        expect(wrapper.state().newAnimalData.species).toEqual(data.species)

        /// / Acquisition Panel
        const acquisitionPanel = wrapper.find('AcquisitionPanel')

        // Acquisition Date
        const acquisitionDatePicker = acquisitionPanel.dive().find('WrappedDatePicker')
        acquisitionDatePicker.simulate('select', data.acquisitionDate)
        await flushPromises()
        expect(wrapper.state().newAnimalData.acqDate).toEqual({ date: moment(data.acquisitionDate) })

        // Acquisition Select
        const acquisitionTypeSelect = acquisitionPanel.dive().find(Select)
        acquisitionTypeSelect.simulate('change', data.acquisitionType)
        await flushPromises()
        expect(wrapper.state().newAnimalData.acquisitionType).toEqual(data.acquisitionType)
    })

    /// / Demographics Panel
    test('Should render demographics page', async () => {
        await setupInitialPage(wrapper).catch(err => {
            console.log(err)
        })
        await pageNext(wrapper, 1).catch(err => { // select the Demographics page
            console.log(err)
        })

        // spinner should be gone
        expect(wrapper.find('LoadingSpinner').exists()).toBeFalsy()
        // Demographics InfoPanel should be present
        const DemographicsPanel = wrapper.find('DemographicsPanel')
        expect(DemographicsPanel.dive().find('InfoPanel').exists()).toBeTruthy()

        // Birthdate state should change -- same as acquisition date
        const birthdateDatePicker = DemographicsPanel.dive().find('WrappedDatePicker')
        birthdateDatePicker.simulate('change', data.birthdate1)
        await flushPromises()

        expect(wrapper.state().newAnimalData.birthDate).toEqual({ date: moment(data.birthdate1) })

        // bdStatus Select
        const bdStatusSelect = DemographicsPanel.dive().find(Select).at(0)
        bdStatusSelect.simulate('change', data.bdStatus)
        await flushPromises()
        expect(wrapper.state().newAnimalData.bdStatus).toEqual(data.bdStatus)

        // Gender Select
        const genderSelect = DemographicsPanel.dive().find(Select).at(1)
        genderSelect.simulate('change', data.gender)
        await flushPromises()
        expect(wrapper.state().newAnimalData.gender).toEqual(data.gender)

        // console.log(DemographicsPanel.dive().debug({ verbose: true }))
        // Potential Dam Select
        const damSelect = DemographicsPanel.dive().find(Select).at(2)
        damSelect.simulate('change', data.potentialDam)
        await flushPromises()
        expect(wrapper.state().newAnimalData.dam).toEqual(data.potentialDam)

        // Potential Sire Select
        const sireSelect = DemographicsPanel.dive().find(Select).at(3)
        sireSelect.simulate('change', data.potentialSire)
        await flushPromises()
        expect(wrapper.state().newAnimalData.sire).toEqual(data.potentialSire)

        // snapshot test
        expect(wrapper).toMatchSnapshot()
        // TODO: birthdate after acqDate should produce error
        // birthdateDatePicker.simulate('change', data.birthdate2);
        // await flushPromises();
        // expect(wrapper.state().newAnimalData.birthDate).toEqual({ date: moment(data.birthdate2) });
    })
})

test('Should render Location page', async () => {
    await setupInitialPage(wrapper).catch(err => {
        console.log(err)
    })
    await pageNext(wrapper, 2).catch(err => { // select the Location page
        console.log(err)
    })
    // spinner should be gone
    expect(wrapper.find('LoadingSpinner').exists()).toBeFalsy()
    // Location InfoPanel should be present
    expect(wrapper.find('LocationPanel').exists()).toBeTruthy()
    expect(wrapper).toMatchSnapshot()
})

test('Should render Account page', async () => {
    await setupInitialPage(wrapper).catch(err => {
        console.log(err)
    })
    await pageNext(wrapper, 3).catch(err => { // select the Account page
        console.log(err)
    })
    // spinner should be gone
    expect(wrapper.find('LoadingSpinner').exists()).toBeFalsy()
    // Account InfoPanel should be present
    expect(wrapper.find('AccountPanel').exists()).toBeTruthy()
    expect(wrapper).toMatchSnapshot()
})

test('Should render Diet page', async () => {
    await setupInitialPage(wrapper).catch(err => {
        console.log(err)
    })
    await pageNext(wrapper, 4).catch(err => { // select the Diet page
        console.log(err)
    })
    // spinner should be gone
    expect(wrapper.find('LoadingSpinner').exists()).toBeFalsy()
    // Diet InfoPanel should be present
    expect(wrapper.find('DietPanel').exists()).toBeTruthy()
    expect(wrapper).toMatchSnapshot()
})
