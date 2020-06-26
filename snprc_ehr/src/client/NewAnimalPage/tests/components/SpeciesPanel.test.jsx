import React from 'react'
import { shallow } from 'enzyme'
import SpeciesPanel from '../../components/SpeciesPanel'
import NewAnimalState from '../../constants/NewAnimalState'
import lists from '../fixtures/lists'

test('Should render the SpeciesPanel', () => {
    const { newAnimalData, selectedOption } = new NewAnimalState()

    const wrapper = shallow(
      <SpeciesPanel
        disabled={ false }
        handleAcquisitionOptionChange={ () => { return false } }
        handleLoadAcuisitionTypes={ () => { return false } }
        handleSpeciesChange={ () => { return false } }
        newAnimalData={ newAnimalData }
        selectedOption={ selectedOption }
        speciesList={ lists.speciesList }
      />
    )
    expect(wrapper).toMatchSnapshot()
})
