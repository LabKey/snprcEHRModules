import timelineReducer from '../../reducers/timelineReducer';
import { timelineData } from '../fixtures/timelineData';

import { TIMELINE_SELECTED } from '../../actions/dataActions';

describe('timelineReducer', () => {
    const timelineState = {
        0: timelineData[0],
        1: timelineData[1],
        errors: [],
        timelines: [...timelineData],
    };

    test('Should select timeline', () => {
        const action = { type: TIMELINE_SELECTED, payload: timelineData[0] };
        const state = timelineReducer(timelineState, action);
        expect(state).toEqual({ ...timelineState, selectedTimeline: timelineData[0] });
    });
});
