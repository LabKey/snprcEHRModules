import React from 'react'
import { shallow } from 'enzyme'
import DietPanel from '../../components/DietPanel'
import NewAnimalState from '../../constants/NewAnimalState'
import lists from '../fixtures/lists'

jest.mock('moment', () => {
    const moment = jest.requireActual('moment')('2023-01-01T00:00:00.000Z');
    return () => moment.utc(0);
});

test('Should render the DietPanel', () => {
    const { newAnimalData } = new NewAnimalState()

    const wrapper = shallow(
      <DietPanel
        dietList={ lists.dietList }
        disabled={ false }
        handleDataChange={ () => { return false } }
        newAnimalData={ newAnimalData }
        preventNext={ () => { return false } }
      />
    )
    expect(wrapper).toMatchSnapshot()
})
