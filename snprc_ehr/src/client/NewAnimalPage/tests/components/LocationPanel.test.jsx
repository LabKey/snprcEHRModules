import React from 'react'
import { shallow } from 'enzyme'
import LocationPanel from '../../components/LocationPanel'
import NewAnimalState from '../../constants/NewAnimalState'
import lists from '../fixtures/lists'

jest.mock('moment', () => {
    const moment = jest.requireActual('moment')('2023-01-01T00:00:00.000Z');
    return () => moment.utc(0);
});

test('Should render the LocationPanel', () => {
    const { newAnimalData } = new NewAnimalState()

    const wrapper = shallow(
      <LocationPanel
        disabled={ false }
        handleDataChange={ () => { return false } }
        handleError={ () => { return false } }
        locationList={ lists.locationList }
        newAnimalData={ newAnimalData }
        preventNext={ () => { return false } }
      />
    )
    expect(wrapper).toMatchSnapshot()
})
