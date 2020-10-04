/* eslint-disable no-unused-vars */

import React from 'react'
import { shallow } from 'enzyme'
import moment from 'moment'
import ReportSelectionPanel from '../../components/ReportSelectionPanel'
import { fetchReportList } from '../../api/fetchReportList'
import { OptionsType } from 'react-select'
import { ReportItem } from '../../api/ReportItem'

let wrapper

beforeEach( async () => {
    
    let reportList: OptionsType<ReportItem> =[]
    await fetchReportList().then ( (response) => {
        ( reportList = response)
    })
    .catch(err => {
        console.log(err)
    })

    wrapper = shallow(<ReportSelectionPanel
        reportList={reportList}
        handleChange={() => {}}
        selectedReport={reportList[0]}
    />)
})

afterEach(() => {
    wrapper.unmount()
})

describe('SelectionReportPanel tests', () => {
    test('Should render the SelectionReportPanel with list data.', () => {
        expect(wrapper).toMatchSnapshot()
    })

})
