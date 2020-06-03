import React from 'react';
import { shallow } from 'enzyme';
import SpeciesPanel from '../../components/SpeciesPanel';
import NewAnimalState from '../../constants/NewAnimalState';
import lists from '../fixtures/lists';

test("Should render the SpeciesPanel", () => {
  const { newAnimalData, selectedOption} = new NewAnimalState();

  const wrapper = shallow (
    <SpeciesPanel
        handleAcquisitionOptionChange={() => { return false; }}
        handleSpeciesChange={() => { return false; }}
        handleLoadAcuisitionTypes={() => { return false; }}
        speciesList={lists.speciesList}
        selectedOption={selectedOption}
        disabled={false}
        newAnimalData={newAnimalData}
    />
  );
    expect(wrapper).toMatchSnapshot();
});
