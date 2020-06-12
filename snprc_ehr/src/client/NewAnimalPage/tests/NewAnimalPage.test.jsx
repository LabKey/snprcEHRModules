import React from 'react';
import { shallow } from 'enzyme';
import NewAnimalPage from '../NewAnimalPage';
import Select from 'react-select';

jest.mock('../../utils/actions/api');
import { request } from '../../utils/actions/api';
import moment from 'moment';


beforeAll(() => {
    //global.fetch = jest.fn();
});

let wrapper;

beforeEach(() => {
    wrapper = shallow(<NewAnimalPage debug={true} />);
});

afterEach(() => {
    wrapper.unmount();
});


function flushPromises() {
    return new Promise(resolve => setImmediate(resolve));
}

const setupInitialPage = async (wrapper) => {
    wrapper.setState({ isLoading: false });
    wrapper.update();

    // select acquisition type
    const value = 'Birth';
    const speciesPanel = wrapper.find('SpeciesPanel');
    speciesPanel.dive().find('Radio').at(0).simulate('change', {
        target: { value }
    });

    // Species Select
    const species = { id: 10, value: "PCA", label: "PCA (PC) - Papio hamadryas anubis/Baboon", arcSpeciesCode: "PC" };
    const speciesSelect = speciesPanel.dive().find(Select);    
    speciesSelect.simulate('change', species);

    // Set Acquisition Date
    const acquisitionPanel = wrapper.find('AcquisitionPanel');
    const acquisitionDate = '2020-06-09T20:00:00.000Z';
    const acquisitionDatePicker = acquisitionPanel.dive().find('WrappedDatePicker');
    acquisitionDatePicker.simulate('select', acquisitionDate);

    await flushPromises();
}

const pageNext = async (wrapper, numPages = 1) => {
    const pagerItem = wrapper.find('PagerItem').at(1);

    for (let i = 0; i < numPages; i++)
        pagerItem.simulate('click');

    //trigger render()
    wrapper.setState({ testing: true });
    wrapper.update();

    await flushPromises();
}

describe('NewAnimalPage tests', () => {

    test("Should render a loading span before api calls.", () => {
        expect(wrapper).toMatchSnapshot();
        expect(wrapper.find("LoadingSpinner_LoadingSpinner").exists()).toBeTruthy();
    });

    test('Should render Species/Acquisition page after lists are loaded.', async () => {

        await flushPromises();

        // spinner should be gone
        expect(wrapper.find("LoadingSpinner_LoadingSpinner").exists()).toBeFalsy();

        // species and acquisition panels should be present
        expect(wrapper.find("SpeciesPanel").exists()).toBeTruthy();
        expect(wrapper.find("AcquisitionPanel").exists()).toBeTruthy();

        // Modals should be present
        expect(wrapper.find('CancelChangeModal').at(0).exists()).toBeTruthy();
        expect(wrapper.find('CancelChangeModal').at(1).exists()).toBeTruthy();
        expect(wrapper.find('SaveModal').exists()).toBeTruthy();

        // InfoPanel should be present
        wrapper.find('AcquisitionPanel').dive().find('InfoPanel');

        // Pager & PagerItems should be present
        expect(wrapper.find("Pager").exists()).toBeTruthy();
        expect(wrapper.find('PagerItem').at(0).exists()).toBeTruthy(); //Previous page
        expect(wrapper.find('PagerItem').at(1).exists()).toBeTruthy(); //Next page
        expect(wrapper.find('PagerItem').at(2).exists()).toBeTruthy(); //Cancel Button

        // componentDidMount should have loaded lists for dropdowns
        expect(wrapper.state('speciesList').length).toBe(3);
        expect(wrapper.state('accountList').length).toBe(3);
        expect(wrapper.state('institutionList').length).toBe(3);
        expect(wrapper.state('dietList').length).toBe(3);

        // snapshot test (full page render after lists have been loaded)
        expect(wrapper).toMatchSnapshot();

        // Make sure birth change updates state correctly
        // Species Radio (acquisition type)
        const value = 'Birth';
        const speciesPanel = wrapper.find('SpeciesPanel');
        speciesPanel.dive().find('Radio').at(0).simulate('change', {
            target: { value }
        });
        await flushPromises();
        expect(wrapper.state('selectedOption')).toBe(value);
        expect(wrapper.state('acquisitionTypeList').length).toBe(3);  // three items in the test data

        // Species Select
       
        const species = { id: 10, value: "PCA", label: "PCA (PC) - Papio hamadryas anubis/Baboon", arcSpeciesCode: "PC" };
        const speciesSelect = speciesPanel.dive().find(Select);
                
        // Test species change & Select component
        speciesSelect.simulate('change', species);
        await flushPromises();
        expect(wrapper.state().newAnimalData.species).toEqual(species);

        //// Acquisition Panel
        const acquisitionPanel = wrapper.find('AcquisitionPanel');

        //Acquisition Date
        const acquisitionDate = '2020-06-09T20:00:00.000Z';
        const acquisitionDatePicker = acquisitionPanel.dive().find('WrappedDatePicker');
        acquisitionDatePicker.simulate('select', acquisitionDate);
        await flushPromises();
        expect(wrapper.state().newAnimalData.acqDate).toEqual({ date: moment(acquisitionDate) });

        // Acquisition Select
        const acquisitionType = {id: 0, value: 1, label: "1 - Colony-born, Vaginal delivery (at TBRI)", Category: "Birth", SortOrder: 1};
        const acquisitionTypeSelect = acquisitionPanel.dive().find(Select);
        acquisitionTypeSelect.simulate('change', acquisitionType);
        await flushPromises();
        expect(wrapper.state().newAnimalData.acquisitionType).toEqual(acquisitionType);

    });

    //// Demographics Panel
    test ('Should render demographics page', async () => {
        
        await setupInitialPage (wrapper).catch(err => {
            console.log(err);
        });
        await pageNext(wrapper, 1).catch( err => {  //select the Demographics page
            console.log(err);
        });
        
        // spinner should be gone
        expect(wrapper.find("LoadingSpinner_LoadingSpinner").exists()).toBeFalsy();        
        // Demographics InfoPanel should be present
        const DemographicsPanel = wrapper.find('DemographicsPanel');
        expect(DemographicsPanel.dive().find('InfoPanel').exists()).toBeTruthy();

        // Gender Select
        const gender = { value: "F", label: "Female" };
        const genderSelect = DemographicsPanel.dive().find(Select).at(0);
        genderSelect.simulate('change', gender);
        await flushPromises();
        expect(wrapper.state().newAnimalData.gender).toEqual(gender);

        // Potential Dam Select
        const potentialDam = {id: 0, value: "12924", label: "12924", ArcSpeciesCode: "PC", Age: 24.7};
        const damSelect = DemographicsPanel.dive().find(Select).at(1);
        damSelect.simulate('change', potentialDam);
        await flushPromises();
        expect(wrapper.state().newAnimalData.dam).toEqual(potentialDam);

        // Potential Sire Select
        const potentialSire = {id: 0, value: "14022", label: "14022", ArcSpeciesCode: "PC",Age: 22.8};
        const sireSelect = DemographicsPanel.dive().find(Select).at(2);
        sireSelect.simulate('change', potentialSire);
        await flushPromises();
        expect(wrapper.state().newAnimalData.sire).toEqual(potentialSire);
        
        //snapshot test
        expect(wrapper).toMatchSnapshot();

        // Birthdate state should change
        const birthdate1 = '2020-06-09T20:00:00.000Z'; // same as acquisition date
        const birthdateDatePicker = DemographicsPanel.dive().find('WrappedDatePicker');
        birthdateDatePicker.simulate('change', birthdate1);
        await flushPromises();

        expect(wrapper.state().newAnimalData.birthDate).toEqual({ date: moment(birthdate1) });

        // TODO: birthdate after acqDate should produce error
        // const birthdate2 = '2020-06-10T20:00:00.000Z'; // after acquisition date
        // birthdateDatePicker.simulate('change', birthdate2);
        // await flushPromises();
        // expect(wrapper.state().newAnimalData.birthDate).toEqual({ date: moment(birthdate2) });

    })

});

test ('Should render Location page', async () => {
    await setupInitialPage (wrapper).catch(err => {
        console.log(err);
    });
    await pageNext(wrapper, 2).catch( err => {  //select the Location page
        console.log(err);
    });
    // spinner should be gone
    expect(wrapper.find("LoadingSpinner_LoadingSpinner").exists()).toBeFalsy();        
    // Location InfoPanel should be present
    expect(wrapper.find('LocationPanel').exists()).toBeTruthy();
    expect(wrapper).toMatchSnapshot();
});

test ('Should render Account page', async () => {
    await setupInitialPage (wrapper).catch(err => {
        console.log(err);
    });
    await pageNext(wrapper, 3).catch( err => {  //select the Account page
        console.log(err);
    });
    // spinner should be gone
    expect(wrapper.find("LoadingSpinner_LoadingSpinner").exists()).toBeFalsy();        
    // Account InfoPanel should be present
    expect(wrapper.find('AccountPanel').exists()).toBeTruthy();
    expect(wrapper).toMatchSnapshot();
});

test ('Should render Diet page', async () => {
    await setupInitialPage (wrapper).catch(err => {
        console.log(err);
    });
    await pageNext(wrapper, 4).catch( err => {  //select the Diet page
        console.log(err);
    });
    // spinner should be gone
    expect(wrapper.find("LoadingSpinner_LoadingSpinner").exists()).toBeFalsy();        
    // Diet InfoPanel should be present
    expect(wrapper.find('DietPanel').exists()).toBeTruthy();
    expect(wrapper).toMatchSnapshot();
});