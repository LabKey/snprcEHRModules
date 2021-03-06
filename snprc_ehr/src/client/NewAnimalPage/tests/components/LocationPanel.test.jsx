import React from 'react'
import { shallow } from 'enzyme'
import LocationPanel from '../../components/LocationPanel'
import NewAnimalState from '../../constants/NewAnimalState'
import lists from '../fixtures/lists'

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
