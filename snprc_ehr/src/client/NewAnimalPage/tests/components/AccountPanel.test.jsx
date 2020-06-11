import React from 'react';
import { shallow } from 'enzyme';
import AccountPanel from '../../components/AccountPanel';
import NewAnimalState from '../../constants/NewAnimalState';
import lists from '../fixtures/lists';


test("Should render the AccountPanel", () => {
  const { newAnimalData } = new NewAnimalState();

  const wrapper = shallow (
    <AccountPanel
      newAnimalData={newAnimalData}
      accountList={lists.accountList}
      colonyList={lists.colonyList}
      iacucList={lists.iacucList}
      pedigreeList={lists.pedigreeList}
      institutionList={lists.institutionList}
      handleDataChange={ () => {return }}
      preventNext={() => { return false; }}
      disabled={false}
    />
  );
    expect(wrapper).toMatchSnapshot();
});
