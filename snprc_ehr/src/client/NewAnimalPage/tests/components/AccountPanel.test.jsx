import React from 'react'
import { shallow } from 'enzyme'
import AccountPanel from '../../components/AccountPanel'
import NewAnimalState from '../../constants/NewAnimalState'
import lists from '../fixtures/lists'

test('Should render the AccountPanel', () => {
    const newAnimalData = {
      ...(NewAnimalState().newAnimalData),
      acquisitionType: { id: 0, value: 1, label: '1 - Colony-born, Vaginal delivery (at TBRI)', Category: 'Birth', SortOrder: 1 }
    }

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
