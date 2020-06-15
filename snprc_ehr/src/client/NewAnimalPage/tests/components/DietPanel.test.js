import React from 'react';
import { shallow } from 'enzyme';
import DietPanel from '../../components/DietPanel';
import NewAnimalState from '../../constants/NewAnimalState';
import lists from '../fixtures/lists';

test("Should render the DietPanel", () => {
  const { newAnimalData } = new NewAnimalState();

  const wrapper = shallow (
    <DietPanel
        dietList={lists.dietList}
        handleDataChange={() => { return false; }}
        newAnimalData={newAnimalData}
        preventNext={() => { return false; }}
        disabled={false}
    />
  );
    expect(wrapper).toMatchSnapshot();
});
