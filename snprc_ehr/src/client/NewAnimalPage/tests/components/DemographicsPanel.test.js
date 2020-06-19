import React from 'react';
import { shallow } from 'enzyme';
import DemographicsPanel from '../../components/DemographicsPanel';
import NewAnimalState from '../../constants/NewAnimalState';
import lists from '../fixtures/lists';

test("Should render the DemographicsPanel", () => {
  const { newAnimalData } = new NewAnimalState();

  const wrapper = shallow (
    <DemographicsPanel
        handleDataChange={() => { return false; }}
        potentialDamList={lists.potentialDamList}
        potentialSireList={lists.potentialSireList}
        bdStatusList={lists.bdStatusList}
        newAnimalData={newAnimalData}
        preventNext={() => { return false; }}
        disabled={false}
    />
  );
    expect(wrapper).toMatchSnapshot();
});
