/* 
    ==================================================================================
    author:             David P. Smith
    email:              dsmith@txbiomed.org
    name:               snprc_scheduler
    description:        Animal procedure scheduling system     
    copyright:          Texas Biomedical Research Institute
    created:            October 3 2018      
    ==================================================================================
*/

import {
    EXPAND_ACCORDION_TAB,
    HIDE_ALERT_BANNER,
    HIDE_ALERT_MODAL,
    HIDE_CONFIRM,
    SHOW_ALERT_BANNER,
    SHOW_ALERT_MODAL,
    SHOW_CONFIRM
} from "../actions/dataActions";

const verboseOutput = false;

export default (state = {}, action) => {
    if (verboseOutput) console.log('rootReducer -> ' + action.type);
    let nextState = Object.assign({ }, state);

    switch (action.type) {

        case EXPAND_ACCORDION_TAB:
            nextState.accordion = {};
            nextState.accordion.tab = action.payload;
            break;
        case SHOW_CONFIRM:
            nextState.confirm = {};
            nextState.confirm.show = true;
            nextState.confirm.title = action.payload.title;
            nextState.confirm.msg = action.payload.msg;
            nextState.confirm.onConfirm = action.payload.onConfirm;
            nextState.confirm.onCancel = action.payload.onCancel;
            break;
        case HIDE_CONFIRM:
            nextState.confirm = {};
            nextState.confirm.show = false;
            break;
        case SHOW_ALERT_MODAL:
            nextState.alertModal = {};
            nextState.alertModal.show = true;
            nextState.alertModal.title = action.payload.title;
            nextState.alertModal.msg = action.payload.msg;
            nextState.alertModal.onDismiss = action.payload.onDismiss;
            break;
        case HIDE_ALERT_MODAL:
            nextState.alertModal = {};
            nextState.alertModal.show = false;
            break;
        case SHOW_ALERT_BANNER:
            nextState.alertBanner = {};
            nextState.alertBanner.show = true;
            nextState.alertBanner.variant = action.payload.variant;
            nextState.alertBanner.msg = action.payload.msg;
            break;
        case HIDE_ALERT_BANNER:
            nextState.alertBanner = {};
            nextState.alertBanner.show = false;
            break;
        default: return { ...state, payload: { }} ;
    };

    return nextState;
};