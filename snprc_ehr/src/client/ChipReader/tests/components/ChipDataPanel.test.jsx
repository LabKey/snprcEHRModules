/* eslint-disable no-unused-vars */

import React from 'react'
import { shallow } from 'enzyme'
import moment from 'moment'
import ChipDataPanel from '../../components/ChipDataPanel'
import constants from '../../constants'

jest.mock('../../services/serialService')

let wrapper

beforeEach(() => {
    wrapper = shallow(<ChipDataPanel
      chipData={ { chipId: undefined, animalId: undefined, temperature: undefined } }
      connection={ undefined }
      errorMessage={ undefined }
      handleDataChange={ () => { } }
      handleErrorMessage={ () => { } }
      handleSetConnection={ () => { } }
      serialOptions={ constants.serialOptions }
    />)
})

afterEach(() => {
    wrapper.unmount()
})

describe('ChipDataPanel tests', () => {
    test('Should render the ChipDataPanel.', () => {
        expect(wrapper).toMatchSnapshot()
    })

    test('Should connect to reader.', () => {
        const connectButton = wrapper.find('#connect')
        connectButton.simulate('click')
        wrapper.setProps({ connection: { port: {} } })
        expect(wrapper).toMatchSnapshot()
        const connectTextEl = wrapper.find('.chip-info-span')
        expect(connectTextEl.text().trim()).toEqual('Reader connected - not reading')
        connectTextEl.unmount()
    })

    test('Should start reading.', () => {
        wrapper.setProps({ connection: { port: {} } }) // test requires a connection object
        const startButton = wrapper.find('#start')
        startButton.simulate('click')
        expect(wrapper).toMatchSnapshot()
        const readTextEl = wrapper.find('.chip-info-span')
        expect(readTextEl.text().trim()).toEqual('Reader connected - reading')
        wrapper.setState({ isReading: false }) // cancel reading after tests (exit read loop)
    })

    test('Should stop reading.', () => {
      // start reading
      wrapper.setProps({ connection: { port: {} } }) // test requires a connection object
      wrapper.find('#start').simulate('click')
      expect(wrapper.find('.chip-info-span').text().trim()).toEqual('Reader connected - reading')

      // quit reading
      const stopButton = wrapper.find('#stop')
      stopButton.simulate('click')
      wrapper.setProps({ connection: undefined, isReading: false }) // close connection object

      expect(wrapper).toMatchSnapshot()
      expect(wrapper.find('.chip-info-span').text().trim()).toEqual('Reader disconnected')
  })
})
