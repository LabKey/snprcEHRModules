//import enzyme, the enzyme adapter, and call a single method to wire up enzyme to work with the adapter

import Enzyme from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

Enzyme.configure({
    adapter: new Adapter()
});

