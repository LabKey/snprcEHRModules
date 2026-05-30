/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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
