/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
import React from 'react'
import { shallow } from 'enzyme'
import DemographicsPanel from '../../components/DemographicsPanel'
import NewAnimalState from '../../constants/NewAnimalState'
import lists from '../fixtures/lists'

jest.mock('moment', () => {
    const moment = jest.requireActual('moment')('2023-01-01T00:00:00.000Z');
    return () => moment.utc(0);
});

test('Should render the DemographicsPanel', () => {
    const { newAnimalData } = new NewAnimalState()

    const wrapper = shallow(
      <DemographicsPanel
        bdStatusList={ lists.bdStatusList }
        disabled={ false }
        handleDataChange={ () => { return false } }
        newAnimalData={ newAnimalData }
        potentialDamList={ lists.potentialDamList }
        potentialSireList={ lists.potentialSireList }
        preventNext={ () => { return false } }
        reloadDamsAndSires={ () => { return false } }
      />
    )
    expect(wrapper).toMatchSnapshot()
})
