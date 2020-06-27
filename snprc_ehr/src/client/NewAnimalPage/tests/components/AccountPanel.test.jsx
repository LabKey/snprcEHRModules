import React from 'react'
import { shallow } from 'enzyme'
import AccountPanel from '../../components/AccountPanel'
import NewAnimalState from '../../constants/NewAnimalState'
import lists from '../fixtures/lists'

test('Should render the AccountPanel', () => {
    const { newAnimalData } = new NewAnimalState()

    const wrapper = shallow(
      <AccountPanel
        accountList={ lists.accountList }
        colonyList={ lists.colonyList }
        disabled={ false }
        handleDataChange={ () => { } }
        iacucList={ lists.iacucList }
        institutionList={ lists.institutionList }
        newAnimalData={ newAnimalData }
        pedigreeList={ lists.pedigreeList }
        preventNext={ () => { return false } }
      />
    )
    expect(wrapper).toMatchSnapshot()
})
