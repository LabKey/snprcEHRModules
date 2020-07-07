import React from 'react'
import { shallow } from 'enzyme'
import AcquisitionPanel from '../../components/AcquisitionPanel'
import NewAnimalState from '../../constants/NewAnimalState'
import lists from '../fixtures/lists'

test('Should render the AcquisitionPanel', () => {
    const { newAnimalData } = new NewAnimalState()

    const wrapper = shallow(
      <AcquisitionPanel
        acquisitionTypeList={ lists.acquisitionTypeList }
        disabled={ false }
        handleDataChange={ () => { } }
        newAnimalData={ newAnimalData }
        preventNext={ () => { return false } }
      />

    )
    expect(wrapper).toMatchSnapshot()
})