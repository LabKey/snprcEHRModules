import React from 'react'
import { shallow } from 'enzyme'
import SaveModal from '../../components/SaveModal'
import CancelChangeModal from '../../components/CancelChangeModal'
import NewAnimalState from '../../constants/NewAnimalState'

jest.mock('moment', () => {
    const moment = jest.requireActual('moment')('2023-01-01T00:00:00.000Z');
    return () => moment.utc(0);
});

describe('Modal tests', () => {
    test('Should render the SaveModal', () => {
        const { newAnimalData } = new NewAnimalState()

        const wrapper = shallow(
          <SaveModal
            newAnimalData={ newAnimalData }
            onCloseClick={ () => { return false } }
            onSaveClick={ () => { return false } }
            show
          />
        )
        expect(wrapper).toMatchSnapshot()
    })

    test('Should render the CancelChangeModal', () => {
        const wrapper = shallow(
          <CancelChangeModal
            message="Are you sure you want to cancel?"
            noClick={ () => { return false } }
            show
            title="Cancel changes?"
            yesClick={ () => { return false } }
          />
        )
        expect(wrapper).toMatchSnapshot()
    })
})
