import React from 'react';
import { shallow } from 'enzyme';
import SummaryPanel from '../../components/SummaryPanel';
import NewAnimalState from '../../constants/NewAnimalState';

test("Should render the SummaryPanel", () => {
  const { newAnimalData } = new NewAnimalState();

  const wrapper = shallow (
    <SummaryPanel
        newAnimalData={newAnimalData}
        infoMessages={[{ key: 1, value: 'Please review data before saving.' },
        { key: 2, value: 'Hover cursor over fields for full text.' }]}
    />
  );
    expect(wrapper).toMatchSnapshot();
});