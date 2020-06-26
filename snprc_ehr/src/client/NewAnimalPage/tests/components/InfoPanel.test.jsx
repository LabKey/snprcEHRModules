import React from 'react'
import { shallow } from 'enzyme'
import InfoPanel from '../../components/InfoPanel'

test('Should render the InfoPanel', () => {
    const wrapper = shallow(
      <InfoPanel
        errorMessages={
                [{ propTest: true, colName: 'Test error message.' }]
            }
        infoMessages={ [{ key: 1, value: 'Please review data before saving.' },
                { key: 2, value: 'Hover cursor over fields for full text.' }] }
        messages={
                [{ propTest: true, colName: 'Location' }]
            }
      />
    )
    expect(wrapper).toMatchSnapshot()
})
