/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
import React from 'react'
import { shallow } from 'enzyme'
import AnimalSelectionPanel from '../../components/AnimalSelectionPanel'
import data from '../fixtures/testData'

test('Should render the AnimalSelectionPanel', () => {
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
