import timelineReducer from '../../reducers/timelineReducer';
import {timelineData} from "../fixtures/timelineData";

import {
    TIMELINE_DUPLICATED,
    TIMELINE_LIST_RECEIVED,
    TIMELINE_SELECTED
} from "../../actions/dataActions";

const timelineState = {
    0: timelineData[0],
    1: timelineData[1],
    errors: [],
    timelines: [...timelineData]
};

test('Should set timeline list', () => {
    const action = {
        type: TIMELINE_LIST_RECEIVED,
        payload: timelineData
    };
    const state = timelineReducer(timelineData, action);
    expect(state).toEqual(
            {
                ...timelineState,
                "selectedTimeline": {}

            });
});

test('Should clone timeline returning a new timeline object with TimelineId = -1, revisionNum = -1, IsDraft = true', () => {
    const action = {
        type: TIMELINE_DUPLICATED,
        payload: timelineData[0]
    };
    const state = timelineReducer(timelineState, action);
    expect(state).toEqual(
            {
                ...timelineState,
                timelines: [ ...timelineData, {...timelineData[0], TimelineId: -1, revisionNum: -1, IsDraft: true} ]

            });
});


test('Should select timeline', () => {
    const action = {
        type: TIMELINE_SELECTED,
        payload: timelineData[0]
    };
    const state = timelineReducer(timelineState, action);
    expect(state).toEqual(
            {
                ...timelineState,
                selectedTimeline: timelineData[0]
            });
});