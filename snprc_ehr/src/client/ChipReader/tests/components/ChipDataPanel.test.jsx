/* eslint-disable no-unused-vars */

import React from 'react'
import { shallow } from 'enzyme'
import moment from 'moment'
import ChipDataPanel from '../../components/ChipDataPanel'
import { requestPort, connect, close } from '../../services/serialService'
import constants from '../../constants'


jest.mock('../../services/serialService')

function flushPromises() {
    return new Promise(resolve => setImmediate(resolve))
}


describe('ChipDataPanel tests', () => {

    test('Should render the ChipDataPanel.', async () => {
        let wrapper = shallow(<ChipDataPanel 
            handleSetConnection={ () => { } }
            handleDataChange={ () => { } }
            handleErrorMessage= { () => { } }
            errorMessage= { undefined }
            chipData={ {chipId: undefined, animalId: undefined, temperature: undefined } }
            serialOptions={ constants.serialOptions }
            connection={ undefined }
        />)
        await flushPromises()
        expect(wrapper).toMatchSnapshot()
        
        wrapper.unmount()
    })

})
