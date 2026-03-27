export const EXPAND_ACCORDION_TAB = "EXPAND_ACCORDION_TAB";
export const PROJECT_LIST_REQUESTED = "PROJECT_LIST_REQUESTED";
export const PROJECT_LIST_RECEIVED = "PROJECT_LIST_RECEIVED";
export const PROJECT_LIST_REQUEST_FAILED = "PROJECT_LIST_REQUEST_FAILED";
export const ANIMAL_LIST_REQUESTED = "ANIMAL_LIST_REQUESTED";
export const ANIMAL_LIST_RECEIVED = "ANIMAL_LIST_RECEIVED";
export const ANIMAL_LIST_REQUEST_FAILED = "ANIMAL_LIST_REQUEST_FAILED";
export const ANIMAL_ASSIGNED = "ANIMAL_ASSIGNED";
export const UPDATE_ASSIGNED_ANIMALS = "UPDATE_ASSIGNED_ANIMALS";
export const AVAILABLE_ANIMAL_LIST_FILTERED = "AVAILABLE_ANIMAL_LIST_FILTERED";
export const ASSIGNED_ANIMAL_LIST_FILTERED = "ASSIGNED_ANIMAL_LIST_FILTERED";
export const PROJECT_SELECTED = "PROJECT_SELECTED";
export const PROJECT_LIST_FILTERED = "PROJECT_LIST_FILTERED";
export const TIMELINE_LIST_REQUESTED = "TIMELINE_LIST_REQUESTED";
export const TIMELINE_LIST_RECEIVED = "TIMELINE_LIST_RECEIVED";
export const TIMELINE_LIST_REQUEST_FAILED = "TIMELINE_LIST_REQUEST_FAILED";
export const TIMELINE_SELECTED = "TIMELINE_SELECTED";
export const TIMELINE_SAVE_SUCCESS = "TIMELINE_SAVE_SUCCESS";
export const UPDATE_SELECTED_TIMELINE = "UPDATE_SELECTED_TIMELINE";
export const ADD_TIMELINE_ANIMAL_ITEM = "ADD_TIMELINE_ANIMAL_ITEM";
export const DELETE_TIMELINE_ANIMAL_ITEM = "DELETE_TIMELINE_ANIMAL_ITEM";
export const UPDATE_TIMELINE_ANIMAL_ITEM = "UPDATE_TIMELINE_ANIMAL_ITEM";
export const TIMELINE_CLONE = "TIMELINE_CLONE";
export const TIMELINE_REVISION = "TIMELINE_REVISION";
export const ADD_TIMELINE_ITEM = "ADD_TIMELINE_ITEM";
export const UPDATE_TIMELINE_ROW = "UPDATE_TIMELINE_ROW";
export const UPDATE_TIMELINE_ITEM = "UPDATE_TIMELINE_ITEM";
export const UPDATE_STUDY_DAY_NOTE = "UPDATE_STUDY_DAY_NOTE";
export const UPDATE_TIMELINE_PROJECT_ITEM = "UPDATE_TIMELINE_PROJECT_ITEM";
export const ASSIGN_TIMELINE_PROCEDURE = "ASSIGN_TIMELINE_PROCEDURE";
export const DELETE_TIMELINE_ITEM = "DELETE_TIMELINE_ITEM";
export const PROJECT_LIST_SORTED = "PROJECT_LIST_SORTED";
export const SET_TIMELINE_DAY_0 = "SET_TIMELINE_DAY_0";
export const NEW_TIMELINE = "NEW_TIMELINE";
export const DELETE_NEW_TIMELINES = "DELETE_NEW_TIMELINES";
export const TIMELINE_CLEAN = "TIMELINE_CLEAN";
export const SHOW_CONFIRM = "SHOW_CONFIRM";
export const HIDE_CONFIRM = "HIDE_CONFIRM";
export const SHOW_ALERT_MODAL = "SHOW_ALERT_MODAL";
export const HIDE_ALERT_MODAL = "HIDE_ALERT_MODAL";
export const SHOW_ALERT_BANNER = "SHOW_ALERT_BANNER";
export const HIDE_ALERT_BANNER = "HIDE_ALERT_BANNER";
export const SHOW_LOADING = "SHOW_LOADING";
export const HIDE_LOADING = "HIDE_LOADING";
export const HAS_PERMISSION = "HAS_PERMISSION";
export const FORCE_RERENDER = "FORCE_RERENDER";

export const TAB_PROJECTS = 0x0;
export const TAB_TIMELINES = 0x1;
export const TAB_ANIMALS = 0x2;

export const getBaseURI = () => {
  let data = (window.location + "").toString().split("//");
  return data[0] + "//" + data[1].split("/")[0];
};

const verboseOutput = false;

export function addDaysToDate(date, days) {
  let result = new Date(date);
  result.setDate(result.getDate() + days);
  return formatDateString(result);
}

export function addTimelineAnimalItem(item, timeline) {
  if (verboseOutput)
    console.log(
      "addTimelineItem(timelineId: " +
        timeline.TimelineId +
        ", animalId: " +
        id +
        ")",
    );
  return (dispatch) => {
    dispatch(createAction(ADD_TIMELINE_ANIMAL_ITEM, item));
    dispatch(
      createAction(UPDATE_ASSIGNED_ANIMALS, timeline.TimelineAnimalItems),
    );
    if (timeline && timeline.IsInUse && timeline.Description) {
      dispatch(
        showAlertBanner({
          msg:
            timeline.Description +
            ", Revision " +
            timeline.RevisionNum +
            " is in use.",
          show: true,
          variant: "warning",
        }),
      );
    } else {
      dispatch(hideAlertBanner());
    }
  };
}

export function addTimelineItem(item) {
  if (verboseOutput) console.log("addTimelineItem(Study Day: " + item.StudyDay);
  return (dispatch) => {
    dispatch(createAction(ADD_TIMELINE_ITEM, item));
  };
}

export function assignAnimal(id) {
  if (verboseOutput) console.log("ANIMAL_ASSIGNED");
  return (dispatch) => {
    dispatch(createAction(ANIMAL_ASSIGNED, id));
  };
}

export function assignTimelineProcedure(item) {
  if (verboseOutput) console.log("ASSIGN_TIMELINE_PROCEDURE");
  return (dispatch) => {
    dispatch(createAction(ASSIGN_TIMELINE_PROCEDURE, item));
  };
}

export function cloneTimeline(timeline) {
  if (verboseOutput) console.log("TIMELINE_CLONE");
  return (dispatch) => {
    dispatch(createAction(TIMELINE_CLONE, timeline));
  };
}

export function createAction(type, payload) {
  switch (type) {
    case ANIMAL_LIST_REQUEST_FAILED:
    case PROJECT_LIST_REQUEST_FAILED:
    case TIMELINE_LIST_REQUEST_FAILED:
      return { error: true, payload: payload, type: type };
    default:
      return { payload: payload, type: type };
  }
}

export function deleteNewTimelines(timeline) {
  if (verboseOutput) console.log("DELETE_NEW_TIMELINES");
  return (dispatch) => {
    dispatch(createAction(DELETE_NEW_TIMELINES, timeline));
  };
}

export function deleteTimelineAnimalItem(id, timeline) {
  if (verboseOutput)
    console.log(
      "deleteTimelineItem(timelineId: " +
        timeline.TimelineId +
        ", animalId: " +
        id +
        ")",
    );
  return (dispatch) => {
    dispatch(createAction(DELETE_TIMELINE_ANIMAL_ITEM, id));
    dispatch(
      createAction(UPDATE_ASSIGNED_ANIMALS, timeline.TimelineAnimalItems),
    );
    if (timeline && timeline.IsInUse && timeline.Description) {
      dispatch(
        showAlertBanner({
          msg:
            timeline.Description +
            ", Revision " +
            timeline.RevisionNum +
            " is in use.",
          show: true,
          variant: "warning",
        }),
      );
    } else {
      dispatch(hideAlertBanner());
    }
  };
}

export function deleteTimelineItem(timelineItem) {
  if (verboseOutput) console.log("DELETE_TIMELINE_ITEM");
  return (dispatch) => {
    dispatch(createAction(DELETE_TIMELINE_ITEM, timelineItem));
  };
}

export function expandAccordionTab(tab) {
  if (verboseOutput) console.log("EXPAND_ACCORDION_TAB");
  return (dispatch) => {
    dispatch(createAction(EXPAND_ACCORDION_TAB, tab));
  };
}

export function fetchAnimalsByProject(projectId, revision) {
  if (verboseOutput)
    console.log("fetchAnimalsByProject(" + projectId + "," + revision + ")");
  return (dispatch) => {
    dispatch(createAction(ANIMAL_LIST_REQUESTED));
    LABKEY.Query.selectRows({
      columns:
        "Id,ProjectId,RevisionNum,StartDate,EndDate,Gender,ChargeId,Iacuc,AssignmentStatus,Weight,Age,status,DeathDate,DepartureDate",
      failure: (error) => {
        dispatch(createAction(ANIMAL_LIST_RECEIVED, []));
        dispatch(handleErrors("Retrieving animals failed", error));
      },
      filterArray: [
        LABKEY.Filter.create(
          "ProjectId",
          projectId.toString(),
          LABKEY.Filter.Types.EQUAL,
        ),
        LABKEY.Filter.create(
          "RevisionNum",
          revision.toString(),
          LABKEY.Filter.Types.EQUAL,
        ),
      ],
      queryName: "AnimalsByProject",
      requiredVersion: 9.1,
      schemaName: "snd",
      success: (results) => {
        dispatch(createAction(ANIMAL_LIST_RECEIVED, results.rows));
      },
    });
  };
}

export function fetchProjects() {
  if (verboseOutput) console.log("fetchProjects()");
  return fetchProjects_SND();
}

export function fetchTimelinesByProject(selectedProject) {
  if (verboseOutput)
    console.log("fetchTimelinesByProject(" + selectedProject.objectId + ")");
  const API_ENDPOINT =
    LABKEY.ActionURL.getBaseURL() +
    LABKEY.ActionURL.getContainer() +
    "/SNPRC_Scheduler-getActiveTimelines.view?projectObjectId=" +
    selectedProject.objectId;
  return (dispatch) => {
    dispatch(createAction(TIMELINE_LIST_REQUESTED, selectedProject.objectId));
    fetch(API_ENDPOINT).then((response) => {
      if (response.status === 403) {
        dispatch(hideLoading());
        dispatch(setPermission(false));
      } else {
        dispatch(setPermission(true));
        response
          .json()
          .then((data) => {
            if (data.success) {
              dispatch(hideLoading()); // last API call in initial loading sequence
              dispatch(
                createAction(TIMELINE_LIST_RECEIVED, {
                  selectedProject: selectedProject,
                  timelines: data.rows,
                }),
              );
            } else {
              dispatch(handleErrors("Retrieving timelines failed", data));
            }
          })
          .catch((error) =>
            dispatch(handleErrors("Retrieving timelines failed", error)),
          );
      }
    }).catch((error) => {
      dispatch(handleErrors("Retrieving timelines failed", error));
    });
  };
}

export function filterAnimals(pattern) {
  if (verboseOutput) console.log("filterAnimals(" + pattern + ")");
  return (dispatch) => {
    dispatch(createAction(ANIMAL_LIST_FILTERED, pattern));
  };
}

export function filterProjects(pattern) {
  if (verboseOutput) console.log("filterProjects(" + pattern + ")");
  return (dispatch) => {
    dispatch(createAction(PROJECT_LIST_FILTERED, pattern));
  };
}

export function formatDateString(date) {
  let newDate = new Date(date);
  return newDate.toISOString().substring(0, "yyyy-MM-dd".length);
}

export function getDay0Date(date, days) {
  let result = new Date(date);
  result.setDate(result.getDate() - days);
  return formatDateString(result);
}

export function getNextRowId(id, timelines) {
  do {
    id++;
  } while (
    timelines.find((timeline) => {
      return timeline.RowId === id;
    })
  );

  return id;
}

export function handleErrors(baseMsg, error) {
  return (dispatch) => {
    dispatch(hideLoading());
    if (error && error.exception) {
      dispatch(
        showAlertBanner({
          msg: baseMsg + ": " + error.exception,
          show: true,
          variant: "danger",
        }),
      );
      console.warn("save project error", error.exception);
    } else if (error && error.errors) {
      dispatch(
        showAlertBanner({
          msg: baseMsg + ": " + error.errors[0].msg,
          show: true,
          variant: "danger",
        }),
      );
      console.warn("save project error", error.errors[0].msg);
    } else if (error && error.message) {
      dispatch(
        showAlertBanner({
          msg: baseMsg + ": " + error.message,
          show: true,
          variant: "danger",
        }),
      );
      console.warn("save project error", error.message);
    }
  };
}

export function hideAlertBanner(alert) {
  if (verboseOutput) console.log("HIDE_ALERT_BANNER");
  return (dispatch) => {
    dispatch(createAction(HIDE_ALERT_BANNER, alert));
  };
}

export function hideAlertModal(alert) {
  if (verboseOutput) console.log("HIDE_ALERT_MODAL");
  return (dispatch) => {
    dispatch(createAction(HIDE_ALERT_MODAL, alert));
  };
}

export function hideConfirm(confirm) {
  if (verboseOutput) console.log("HIDE_CONFIRM");
  return (dispatch) => {
    dispatch(createAction(HIDE_CONFIRM, confirm));
  };
}

export function hideLoading() {
  if (verboseOutput) console.log("HIDE_LOADING");
  return (dispatch) => {
    dispatch(createAction(HIDE_LOADING));
  };
}

export function newTimeline(timeline, selectedProject) {
  if (verboseOutput) console.log("NEW_TIMELINE");
  return (dispatch) => {
    dispatch(
      createAction(NEW_TIMELINE, {
        selectedProject: selectedProject,
        timeline: timeline,
      }),
    );
    dispatch(createAction(UPDATE_ASSIGNED_ANIMALS, []));
  };
}

export function reviseTimeline(timeline) {
  if (verboseOutput) console.log("TIMELINE_REVISION");
  return (dispatch) => {
    dispatch(createAction(TIMELINE_REVISION, timeline));
    dispatch(createAction(UPDATE_ASSIGNED_ANIMALS, timeline.TimelineAnimalItems || []));
  };
}

export function saveTimeline(timelineData) {
  return new Promise((resolve, reject) => {
    LABKEY.Ajax.request({
      failure: LABKEY.Utils.getCallbackWrapper((data) => {
        reject(data);
      }),
      jsonData: timelineData,
      method: "POST",
      success: LABKEY.Utils.getCallbackWrapper((data) => {
        resolve(data);
      }),
      url: LABKEY.ActionURL.buildURL("SNPRC_scheduler", "updateTimeline.api"),
    });
  });
}

// export function duplicateTimeline(timeline) {
//     if (verboseOutput) console.log('duplicateTimeline(' + timeline.TimelineId + ',' + timeline.RevisionNum + ')');
//     return (dispatch) => {
//         dispatch(createAction(TIMELINE_DUPLICATED, timeline));
//     }
// }

export function saveTimelineSuccess(timeline) {
  if (verboseOutput) console.log("updateSelectedTimeline");
  return (dispatch) => {
    dispatch(createAction(TIMELINE_SAVE_SUCCESS, timeline));
  };
}

export function selectFirstTimeline(timelines) {
  if (timelines) {
    timelines = sortTimelines(timelines);
    return selectTimeline(timelines[0]);
  }
}

export function selectProject(selectedProject) {
  if (verboseOutput)
    console.log(
      "selectProject(" +
        selectedProject.projectId +
        "," +
        selectedProject.revisionNum +
        ")",
    );
  return (dispatch) => {
    dispatch(createAction(PROJECT_SELECTED, selectedProject.projectId));
    dispatch(
      fetchAnimalsByProject(
        selectedProject.projectId,
        selectedProject.revisionNum,
      ),
    );
    dispatch(fetchTimelinesByProject(selectedProject)); // This will hide loading mask on success
  };
}

export function selectTimeline(timeline) {
  if (verboseOutput)
    console.log(
      "selectTimeline(" +
        timeline.TimelineId +
        "," +
        timeline.RevisionNum +
        ")",
    );
  return (dispatch) => {
    dispatch(createAction(TIMELINE_SELECTED, timeline));
    dispatch(
      createAction(
        UPDATE_ASSIGNED_ANIMALS,
        timeline ? timeline.TimelineAnimalItems : [],
      ),
    );
    if (timeline && timeline.IsInUse && timeline.Description) {
      dispatch(
        showAlertBanner({
          msg:
            timeline.Description +
            ", Revision " +
            timeline.RevisionNum +
            " is in use.",
          show: true,
          variant: "warning",
        }),
      );
    } else {
      dispatch(hideAlertBanner());
    }
  };
}

export function setAssignedAnimalFilter(filter) {
  if (verboseOutput) console.log("ASSIGNED_ANIMAL_LIST_FILTERED");
  return (dispatch) => {
    dispatch(createAction(ASSIGNED_ANIMAL_LIST_FILTERED, filter));
  };
}

export function setAvailableAnimalFilter(filter) {
  if (verboseOutput) console.log("AVAILABLE_ANIMAL_LIST_FILTERED");
  return (dispatch) => {
    dispatch(createAction(AVAILABLE_ANIMAL_LIST_FILTERED, filter));
  };
}

export function setForceRerender(render) {
  if (verboseOutput) console.log("FORCE_RERENDER");
  return (dispatch) => {
    dispatch(createAction(FORCE_RERENDER, render));
  };
}

export function setPermission(permission) {
  if (verboseOutput) console.log("HAS_PERMISSION");
  return (dispatch) => {
    dispatch(createAction(HAS_PERMISSION, permission));
  };
}

export function setTimelineClean(timeline) {
  if (verboseOutput) console.log("TIMELINE_CLEAN");
  return (dispatch) => {
    dispatch(createAction(TIMELINE_CLEAN, timeline));
  };
}

export function setTimelineDayZero(day0, forceReload, dirty) {
  if (verboseOutput) console.log("SET_TIMELINE_DAY_0");
  return (dispatch) => {
    dispatch(
      createAction(SET_TIMELINE_DAY_0, {
        day0: day0,
        dirty: dirty,
        forceReload: forceReload,
      }),
    );
  };
}

export function showAlertBanner(alert) {
  if (verboseOutput) console.log("SHOW_ALERT_BANNER");
  return (dispatch) => {
    dispatch(createAction(SHOW_ALERT_BANNER, alert));
  };
}

export function showAlertModal(alert) {
  if (verboseOutput) console.log("SHOW_ALERT_MODAL");
  return (dispatch) => {
    dispatch(createAction(SHOW_ALERT_MODAL, alert));
  };
}

export function showConfirm(confirm) {
  if (verboseOutput) console.log("SHOW_CONFIRM");
  return (dispatch) => {
    dispatch(createAction(SHOW_CONFIRM, confirm));
  };
}

export function showLoading() {
  if (verboseOutput) console.log("SHOW_LOADING");
  return (dispatch) => {
    dispatch(createAction(SHOW_LOADING));
  };
}

export function sortProjects(field, direction) {
  if (verboseOutput)
    console.log("sortProjects(" + field + "," + direction + ")");
  return (dispatch) => {
    dispatch(
      createAction(PROJECT_LIST_SORTED, { direction: direction, field: field }),
    );
  };
}

export function sortTimelines(timelines) {
  timelines = timelines.sort(function (a, b) {
    if (!a.Description) {
      return 1;
    }
    if (!b.Description) {
      return -1;
    }

    if (a.Description === b.Description) {
      return a.RevisionNum > b.RevisionNum ? 1 : -1;
    }
    return a.Description > b.Description ? 1 : -1;
  });

  return timelines;
}

export function updateSelectedTimeline(timeline, dirty) {
  if (verboseOutput) console.log("updateSelectedTimeline");
  return (dispatch) => {
    dispatch(
      createAction(UPDATE_SELECTED_TIMELINE, {
        dirty: dirty,
        timeline: timeline,
      }),
    );
  };
}

export function updateStudyDayNote(note, dirty) {
  if (verboseOutput)
    console.log("UPDATE_STUDY_DAY_NOTE - Study Day: " + note.StudyDay);
  return (dispatch) => {
    dispatch(createAction(UPDATE_STUDY_DAY_NOTE, { dirty: dirty, note: note }));
  };
}

export function updateTimelineAnimalItem(item, timeline) {
  if (verboseOutput)
    console.log(
      "enddateTimelineAnimalItem(timelineId: " +
        timeline.TimelineId +
        ", animalId: " +
        item.AnimalId +
        ")",
    );
  return (dispatch) => {
    dispatch(createAction(UPDATE_TIMELINE_ANIMAL_ITEM, item));
    dispatch(
      createAction(UPDATE_ASSIGNED_ANIMALS, timeline.TimelineAnimalItems),
    );
    if (timeline && timeline.IsInUse && timeline.Description) {
      dispatch(
        showAlertBanner({
          msg:
            timeline.Description +
            ", Revision " +
            timeline.RevisionNum +
            " is in use.",
          show: true,
          variant: "warning",
        }),
      );
    } else {
      dispatch(hideAlertBanner());
    }
  };
}

export function updateTimelineItem(item, dirty) {
  if (verboseOutput)
    console.log("updateTimelineItem - Study Day: " + item.StudyDay);
  return (dispatch) => {
    dispatch(createAction(UPDATE_TIMELINE_ITEM, { dirty: dirty, item: item }));
  };
}

export function updateTimelineProjectItem(projectItem) {
  if (verboseOutput) console.log("UPDATE_TIMELINE_PROJECT_ITEM");
  return (dispatch) => {
    dispatch(createAction(UPDATE_TIMELINE_PROJECT_ITEM, projectItem));
  };
}

export function updateTimelineRow(item) {
  if (verboseOutput)
    console.log("updateTimelineRow - Study Day: " + item.StudyDay);
  return (dispatch) => {
    dispatch(createAction(UPDATE_TIMELINE_ROW, item));
  };
}

function fetchProjects_LABKEY() {
  return (dispatch) => {
    dispatch(createAction(PROJECT_LIST_REQUESTED));
    LABKEY.Query.selectRows({
      columns:
        "ProjectId,RevisionNum,ChargeId,Description,StartDate,EndDate,ProjectType,VsNumber,Active,ObjectId,iacuc,veterinarian",
      failure: (error) => {
        dispatch(createAction(PROJECT_LIST_REQUEST_FAILED, error));
      },
      filterArray: [],
      queryName: "ProjectDetails",
      requiredVersion: 9.1,
      schemaName: "snd",
      sort: "ProjectId,RevisionNum",
      success: (results) => {
        dispatch(createAction(PROJECT_LIST_RECEIVED, results.rows));
      },
    });
  };
}

function fetchProjects_SND() {
  const API_ENDPOINT =
    LABKEY.ActionURL.getBaseURL() +
    LABKEY.ActionURL.getContainer() +
    "/SNPRC_Scheduler-getActiveProjects.view";
  return (dispatch) => {
    dispatch(showLoading());
    dispatch(createAction(PROJECT_LIST_REQUESTED));
    fetch(API_ENDPOINT)
      .then((response) => {
        if (response.status === 403) {
          dispatch(hideLoading());
          dispatch(setPermission(false));
        } else {
          dispatch(setPermission(true));
          response.json().then((data) => {
            if (data.success) {
              dispatch(createAction(PROJECT_LIST_RECEIVED, data.rows));

              // Sort matches defaultSort on projects table to select first project
              dispatch(
                selectProject(
                  data.rows.sort(function (a, b) {
                    if (!a.description) {
                      return 1;
                    }
                    if (!b.description) {
                      return -1;
                    }
                    return a.description > b.description ? 1 : -1;
                  })[0],
                ),
              );
            } else {
              console.error("Retrieving projects failed.", data.message);
              dispatch(handleErrors("Retrieving projects failed.", data));
            }
          }).catch((error) => {
            console.error("Retrieving projects failed", error);
            dispatch(handleErrors("Retrieving projects failed", error));
          });
        }
      })
      .catch((error) => {
        console.error("Retrieving projects failed", error);
        dispatch(handleErrors("Retrieving projects failed", error));
      });
  };
}
