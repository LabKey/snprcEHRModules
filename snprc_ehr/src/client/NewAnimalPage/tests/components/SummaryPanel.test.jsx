import React from 'react'
import { shallow } from 'enzyme'
import SummaryPanel from '../../components/SummaryPanel'
import NewAnimalState from '../../constants/NewAnimalState'

describe('AcquisitionPanel tests', () => {
  test('Should render the SummaryPanel', () => {
    const { newAnimalData } = new NewAnimalState()

    const wrapper = shallow(
      <SummaryPanel
        infoMessages={ [{ key: 1, value: 'Please review data before saving.' },
        { key: 2, value: 'Hover cursor over fields for full text.' }] }
        newAnimalData={ newAnimalData }

        includeBullets={ true }
      />
    )
    expect(wrapper).toMatchSnapshot()
  })

  test('Should render the SummaryPanel for multiple acquisitions', () => {
    const newAnimalData = {
      ...(NewAnimalState().newAnimalData),
      species: { value: 'HAM', arcSpeciesCode: 'MA' }
    }

    const wrapper = shallow(
      <SummaryPanel
        infoMessages={ [{ key: 1, value: 'Multiple animals are being addeded!' },
          { key: 2, value: 'Please review data before saving.' },
          { key: 3, value: 'Hover cursor over fields for full text.' }] }
        newAnimalData={ newAnimalData }
        numAnimals={ 2 }
      />
    )
    expect(wrapper).toMatchSnapshot()
  })
})
