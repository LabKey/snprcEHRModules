/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
import React from 'react'
import { shallow } from 'enzyme'
import moment from 'moment'
import WrappedDatePicker from '../../components/WrappedDatePicker'

jest.mock('moment', () => {
    return () => jest.requireActual('moment')('2023-01-01T00:00:00.000Z');
});

test('Should render the WrappedDatePicker', () => {
    const wrapper = shallow(
      <WrappedDatePicker
        dateFormat="Pp"
        disabled={ false }
        id="acquisition-datepicker"
        label="Acquisition Date"
        maxDate={ moment().toDate() }
        onChange={ () => {} }
        onSelect={ () => {} }
        selected={ moment().toDate() }
        showTimeSelect
        timeFormat="p"
        timeIntervals={ 30 }
        todayButton="Today"
      />
    )
    expect(wrapper).toMatchSnapshot()
})
