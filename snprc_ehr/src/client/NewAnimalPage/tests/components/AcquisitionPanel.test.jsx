import React from 'react'
import { shallow } from 'enzyme'
import AcquisitionPanel from '../../components/AcquisitionPanel'
import NewAnimalState from '../../constants/NewAnimalState'
import lists from '../fixtures/lists'

describe('AcquisitionPanel tests', () => {
  test('Should render the AcquisitionPanel', () => {
    const { newAnimalData } = NewAnimalState()

    const wrapper = shallow(
      <AcquisitionPanel
        acquisitionTypeList={ lists.acquisitionTypeList }
        disabled={ false }
        handleDataChange={ () => { } }
        newAnimalData={ newAnimalData }
        preventNext={ () => { return false } }
        numAnimals= { undefined }
        handleNumAnimalChange={ () => {} }
      />

    )
    expect(wrapper).toMatchSnapshot()
  })

  test('Should render the AcquisitionPanel for multiple animal acquisition', () => {
    const newAnimalData = { ...(NewAnimalState().newAnimalData),
                            species: {value: 'HAM', arcSpeciesCode: 'MA' }
    }
    
    const wrapper = shallow(
      <AcquisitionPanel
        acquisitionTypeList={ lists.acquisitionTypeList }
        disabled={ false }
        handleDataChange={ () => { } }
        newAnimalData={ newAnimalData }
        preventNext={ () => { return false } }
        numAnimals={ 2 }
        handleNumAnimalChange={ () => {} }
      />

    )
    expect(wrapper).toMatchSnapshot()
  })
})
