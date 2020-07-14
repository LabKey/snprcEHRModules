import React from 'react'
import { shallow } from 'enzyme'
import moment from 'moment'
import WrappedDatePicker from '../../components/WrappedDatePicker'

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
