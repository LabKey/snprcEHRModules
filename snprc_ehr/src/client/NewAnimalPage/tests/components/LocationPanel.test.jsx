import React from 'react';
import { shallow } from 'enzyme';
import LocationPanel from '../../components/LocationPanel';
import NewAnimalState from '../../constants/NewAnimalState';
import lists from '../fixtures/lists';

test("Should render the LocationPanel", () => {
  const { newAnimalData } = new NewAnimalState();

  const wrapper = shallow (
    <LocationPanel
        locationList={lists.locationList}
        handleDataChange={() => { return false; }}
        newAnimalData={newAnimalData}
        handleError={() => { return false; }}
        preventNext={() => { return false; }}
        disabled={false}
    />
  );
    expect(wrapper).toMatchSnapshot();
});
