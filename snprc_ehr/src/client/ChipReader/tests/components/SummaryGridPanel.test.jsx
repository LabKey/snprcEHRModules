/* eslint-disable no-unused-vars */

import React from 'react'
import { shallow } from 'enzyme'
import moment from 'moment'
import SummaryGridPanel from '../../components/SummaryGridPanel'
import { summaryData } from '../fixtures/apiTestData'

function flushPromises() {
    return new Promise(resolve => setImmediate(resolve))
}

describe('SummaryGridPanel tests', () => {
    test('Should render empty SummaryGridPanel.', async () => {
        const mathRandomSpy = jest.spyOn(Math, 'random')
        mathRandomSpy.mockImplementation(() => 0.5)

        const wrapper = shallow(<SummaryGridPanel
          summaryData={ summaryData }

        />)
        await flushPromises()
        expect(wrapper).toMatchSnapshot()
        wrapper.unmount()
    })
})
