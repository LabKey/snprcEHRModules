import React from 'react'
import { shallow } from 'enzyme'
import SummaryPopover from '../../components/SummaryPopover'

test('Should render the SummaryPopover', () => {
    const wrapper = shallow(
      <SummaryPopover
        message="Summary popover test"
        title="popover"
      />
    )
    expect(wrapper).toMatchSnapshot()
})
