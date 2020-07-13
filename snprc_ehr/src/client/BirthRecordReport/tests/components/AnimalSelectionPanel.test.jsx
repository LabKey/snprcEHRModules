import React from 'react'
import { shallow } from 'enzyme'
import AnimalSelectionPanel from '../../components/AnimalSelectionPanel'
import data from '../fixtures/testData'

test('Should render the AccountPanel', () => {
    const { animalList } = data
    const wrapper = shallow(
      <AnimalSelectionPanel
        animalList={ animalList }
        handleChange={ () => { } }
        selectedAnimal={ undefined }
      />
    )
    expect(wrapper).toMatchSnapshot()
})
