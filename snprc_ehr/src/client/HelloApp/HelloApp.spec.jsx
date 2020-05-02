import React from 'react';
import {shallow } from 'enzyme';
import HelloApp from './HelloApp';

describe('<HelloApp/>', () => {
    test('Should render LandingPage correctly.', () => {
        const wrapper = shallow(<HelloApp/>);

        expect(wrapper).toMatchSnapshot();
    });
});