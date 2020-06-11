import React from 'react';
import { shallow } from 'enzyme';
import {SaveModal, CancelChangeModal} from '../../components/Modals';
import NewAnimalState from '../../constants/NewAnimalState';

describe ('Modal tests', ()=> {
    test("Should render the SaveModal", () => {
        const { newAnimalData } = new NewAnimalState();
    
        const wrapper = shallow (
            < SaveModal  
                show={true}
                onCloseClick={() => { return false; }}
                onSaveClick={() => { return false; }}
                newAnimalData={newAnimalData}
            />
        );
        expect(wrapper).toMatchSnapshot();
    });

    test("Should render the CancelChangeModal", () => {
        const { newAnimalData } = new NewAnimalState();
    
        const wrapper = shallow (
            < CancelChangeModal 
                show={true}
                yesClick={() => { return false; }}
                noClick={() => { return false; }}
                title={'Cancel changes?'}
                message={ 'Are you sure you want to cancel?'}
            />
        );
        expect(wrapper).toMatchSnapshot();
    });
})
    