import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

// Enzyme expects an adapter to be configured
// http://airbnb.io/enzyme/docs/installation/react-16.html
configure({ adapter: new Adapter() });
