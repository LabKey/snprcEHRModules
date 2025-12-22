import {
  ADD_TIMELINE_ANIMAL_ITEM,
  ADD_TIMELINE_ITEM,
  addDaysToDate,
  ASSIGN_TIMELINE_PROCEDURE,
  DELETE_NEW_TIMELINES,
  DELETE_TIMELINE_ANIMAL_ITEM,
  DELETE_TIMELINE_ITEM,
  formatDateString,
  getDay0Date,
  getNextRowId,
  NEW_TIMELINE,
  SET_TIMELINE_DAY_0,
  TIMELINE_CLEAN,
  TIMELINE_CLONE,
  TIMELINE_LIST_RECEIVED,
  TIMELINE_REVISION,
  TIMELINE_SAVE_SUCCESS,
  TIMELINE_SELECTED,
  UPDATE_SELECTED_TIMELINE,
  UPDATE_STUDY_DAY_NOTE,
  UPDATE_TIMELINE_ANIMAL_ITEM,
  UPDATE_TIMELINE_ITEM,
  UPDATE_TIMELINE_PROJECT_ITEM,
  UPDATE_TIMELINE_ROW,
} from "../actions/dataActions";
import { verboseOutput } from "./projectReducer";

// Used for cloning or revising a timeline
const cloneTimeline = (source, revision) => {
  // Calculate new start date for revisions: day after the source timeline's end date
  let newStartDate = undefined;
  if (revision && source.EndDate) {
    const endDate = new Date(source.EndDate);
    endDate.setDate(endDate.getDate() + 1);
    newStartDate = endDate.toISOString().split("T")[0];
  }

  // let newTimeline = { ...source };
  let newTimeline = {
    ...source,
    Created: undefined,
    CreatedBy: undefined,
    CreatedByName: undefined,
    Description: source.Description + (revision ? "" : " Clone"),
    EndDate: undefined,
    forceReload: false,
    isChild: false,
    IsDirty: true,
    Modified: undefined,
    ModifiedBy: undefined,
    ModifiedByName: undefined,
    ObjectId: undefined,
    QcStateLabel: "In Progress",
    RevisionNum: revision,
    RowId: revision ? source.RowId : 0,
    StartDate: newStartDate,
    TimelineId: revision ? source.TimelineId : undefined,
  };
  newTimeline.TimelineItems = newTimeline.TimelineItems.map((item) => {
    return {
      ...item,
      IsDirty: true,
      ObjectId: undefined,
      TimelineItemId: undefined,
      TimelineObjectId: undefined,
    };
  });
  newTimeline.TimelineProjectItems = newTimeline.TimelineProjectItems.map(
    (item) => {
      return {
        ...item,
        IsDirty: true,
        ObjectId: undefined,
        TimelineObjectId: undefined,
      };
    },
  );

  newTimeline.TimelineProjectItems = newTimeline.TimelineProjectItems.map(
    (item) => {
      return {
        ...item,
        IsDirty: true,
      };
    },
  );

  newTimeline.StudyDayNotes = newTimeline.StudyDayNotes.map((note) => {
    return {
      ...note,
      IsDirty: true,
      TimelineObjectId: undefined,
    };
  });

  return newTimeline;
};

const cloneArray = (timelines) => {
  return timelines.map((timeline) => {
    return timeline;
  });
};

const setStudyDay0 = (selectedTimeline) => {
  if (
    selectedTimeline &&
    !selectedTimeline.StudyDay0 &&
    selectedTimeline.TimelineItems.length > 0 &&
    selectedTimeline.TimelineItems[0].ScheduleDate
  ) {
    const date = new Date(selectedTimeline.TimelineItems[0].ScheduleDate);
    selectedTimeline.StudyDay0 = getDay0Date(
      formatDateString(date),
      parseInt(selectedTimeline.TimelineItems[0].StudyDay),
    );
  }

  return selectedTimeline;
};

export default (state = {}, action) => {
  let nextState = { ...state };
  nextState.errors = [];
  switch (action.type) {
    case ADD_TIMELINE_ANIMAL_ITEM:
      // action payload is the animal item
      if (
        nextState.selectedTimeline &&
        nextState.selectedTimeline.TimelineAnimalItems
      ) {
        nextState.selectedTimeline.TimelineAnimalItems.push(action.payload);
      }

      nextState.selectedTimeline.IsDirty = true;
      break;
    case ADD_TIMELINE_ITEM:
      // action payload is the timeline item
      if (
        nextState.selectedTimeline &&
        nextState.selectedTimeline.TimelineItems
      ) {
        nextState.selectedTimeline.TimelineItems.push(action.payload);
      }

      nextState.selectedTimeline.IsDirty = true;
      break;
    case ASSIGN_TIMELINE_PROCEDURE:
      // action.payload timeline item
      nextState.selectedTimeline.IsDirty = true;

      // Unchecking
      if (action.payload.Value === false) {
        // If unchecking a project item not persisted in db then just erase it
        nextState.selectedTimeline.TimelineItems =
          nextState.selectedTimeline.TimelineItems.filter(
            (item) =>
              item.ObjectId ||
              action.payload.ProjectItemId !== item.ProjectItemId ||
              action.payload.RowIdx !== item.RowIdx,
          );

        // If persisted set IsDeleted flag
        nextState.selectedTimeline.TimelineItems =
          nextState.selectedTimeline.TimelineItems.map((item) => {
            if (
              item.ObjectId &&
              action.payload.ProjectItemId === item.ProjectItemId &&
              action.payload.RowIdx === item.RowIdx
            ) {
              item.IsDeleted = true;
            }

            return item;
          });

        const otherRowValues = nextState.selectedTimeline.TimelineItems.filter(
          (item) =>
            item.StudyDay === action.payload.StudyDay && !item.IsDeleted,
        );

        // Add a null timeline item if deleting all items on a study day
        if (otherRowValues.length === 0) {
          nextState.selectedTimeline.TimelineItems.push({
            ...action.payload,
            IsDeleted: false,
            IsDirty: true,
            ObjectId: null,
            ProjectItemId: null,
          });
        }
      }
      // Check
      else {
        let found = false;

        // If matching item with IsDeleted = true, than set IsDeleted = false
        nextState.selectedTimeline.TimelineItems =
          nextState.selectedTimeline.TimelineItems.map((item) => {
            if (
              item.ProjectItemId === action.payload.ProjectItemId &&
              action.payload.StudyDay === item.StudyDay &&
              item.IsDeleted
            ) {
              item.IsDeleted = false;
              item.IsDirty = false;
              found = true;
            }

            return item;
          });

        if (!found) {
          // If empty project item saved
          nextState.selectedTimeline.TimelineItems =
            nextState.selectedTimeline.TimelineItems.map((item) => {
              if (
                !item.ProjectItemId &&
                action.payload.RowIdx === item.RowIdx
              ) {
                item.ProjectItemId = action.payload.ProjectItemId;
                item.IsDirty = true;
                found = true;
              }

              return item;
            });
        }

        if (!found) {
          // New item
          nextState.selectedTimeline.TimelineItems.push({
            IsDeleted: false,
            IsDirty: false,
            ProjectItemId: action.payload.ProjectItemId,
            RowIdx: action.payload.RowIdx,
            ScheduleDate: action.payload.ScheduleDate,
            StudyDay: action.payload.StudyDay,
            TimelineObjectId: action.payload.TimelineObjectId,
          });
        }
      }

      nextState.selectedTimeline.IsDirty = true;

      break;
    case DELETE_NEW_TIMELINES:
      // action.payload is unsaved timeline NOT to delete
      nextState.timelines = nextState.timelines.filter((timeline) => {
        return (
          timeline.ObjectId ||
          (action.payload &&
            action.payload.RowId === timeline.RowId &&
            action.payload.RevisionNum === timeline.RevisionNum)
        );
      });
      break;
    case DELETE_TIMELINE_ANIMAL_ITEM:
      // action payload is the animal id
      if (
        nextState.selectedTimeline &&
        nextState.selectedTimeline.TimelineAnimalItems
      ) {
        nextState.selectedTimeline.TimelineAnimalItems =
          nextState.selectedTimeline.TimelineAnimalItems.map((item) => {
            if (item.AnimalId === action.payload) {
              return { ...item, IsDeleted: true, IsDirty: true };
            }
            return item;
          });
      }

      nextState.selectedTimeline.IsDirty = true;
      break;
    case DELETE_TIMELINE_ITEM:
      // action.payload timeline item
      nextState.selectedTimeline.TimelineItems =
        nextState.selectedTimeline.TimelineItems.filter((item) => {
          if (item.RowIdx === action.payload.RowIdx) {
            if (item.ObjectId) {
              item.IsDeleted = true;
              return true;
            } else return false;
          }
          return true;
        });

      nextState.selectedTimeline.StudyDayNotes =
        nextState.selectedTimeline.StudyDayNotes.filter((note) => {
          if (note.RowIdx === action.payload.RowIdx) {
            if (note.ObjectId) {
              note.IsDeleted = true;
              return true;
            } else return false;
          }
          return true;
        });

      nextState.selectedTimeline.IsDirty = true;

      break;
    case NEW_TIMELINE:
      const timelineTemplate = {
        Description: "New Timeline",
        IsDeleted: false,
        IsDirty: true,
        QcStateLabel: "In Progress",
        RevisionNum: 0,
        RowId: getNextRowId(nextState.lastRowId, nextState.timelines),
        StudyDayNotes: [],
        TimelineAnimalItems: [],
        TimelineItems: [
          {
            IsDeleted: false,
            IsDirty: true,
            RowIdx: 1,
            ScheduleDate: null,
            StudyDay: 0,
          },
        ],
      };

      let newTimeline = { ...timelineTemplate, ...action.payload.timeline };
      newTimeline.TimelineProjectItems =
        action.payload.selectedProject.ProjectItems.map((item) => {
          return {
            IsDeleted: false,
            IsDirty: false,
            ProjectItemId: item.projectItemId,
            SortOrder: item._row - 1,
            TimelineFootNotes: null,
          };
        });

      if (nextState.timelines) {
        nextState.timelines = cloneArray(nextState.timelines);
        nextState.timelines.push(newTimeline);
        nextState.selectedTimeline = newTimeline;
      }

      nextState.lastRowId = newTimeline.RowId;
      break;
    case SET_TIMELINE_DAY_0:
      const { day0, forceReload } = action.payload;

      nextState.selectedTimeline = { ...nextState.selectedTimeline };

      if (day0) {
        // Set in selected timeline for timeline details
        nextState.selectedTimeline.StudyDay0 = formatDateString(day0);
      } else {
        // Clearing day0
        nextState.selectedTimeline.StudyDay0 = day0;
      }

      // Calculate and update or clear timeline items scheduled dates
      let newTimelineItems = nextState.selectedTimeline.TimelineItems.map(
        (item) => {
          item = { ...item };
          if (
            day0 &&
            item.StudyDay !== "" &&
            typeof item.StudyDay !== "undefined"
          ) {
            item.ScheduleDate = addDaysToDate(day0, parseInt(item.StudyDay));
          } else {
            item.ScheduleDate = null;
          }
          item.IsDirty = true;
          return item;
        },
      );

      nextState.selectedTimeline.TimelineItems = newTimelineItems;
      nextState.selectedTimeline.forceReload = forceReload;

      if (typeof action.payload.dirty !== "undefined") {
        nextState.selectedTimeline.IsDirty =
          action.payload.dirty || nextState.selectedTimeline.IsDirty;
      } else {
        nextState.selectedTimeline.IsDirty = true;
      }

      break;
    case TIMELINE_CLEAN:
      nextState.selectedTimeline.IsDirty = false;
      break;
    case TIMELINE_CLONE:
      // action.payload is source timeline revision
      const clone = cloneTimeline(action.payload, 0);
      clone.RowId = getNextRowId(nextState.lastRowId, nextState.timelines);
      nextState.lastRowId = clone.RowId;
      nextState.timelines = cloneArray(nextState.timelines);
      nextState.timelines.push(clone);
      nextState.selectedTimeline = clone;
      break;
    case TIMELINE_LIST_RECEIVED:
      // action payload is the timeline array
      nextState.timelines = action.payload.timelines;

      // Add rowid, timelineitems, timelineprojectitems and timelineanimalitems for UI
      for (const tl of nextState.timelines) {
        tl.RowId = tl.TimelineId;
        tl.savedDraft = tl.QcStateLabel === "In Progress";

        if (!tl.TimelineItems) {
          tl.TimelineItems = [];
        }

        if (!tl.TimelineProjectItems) {
          tl.TimelineProjectItems =
            action.payload.selectedProject.ProjectItems.map((item, index) => {
              return { ProjectItemId: item.projectItemId, SortOrder: index };
            });
        }

        if (!tl.TimelineAnimalItems) {
          tl.TimelineAnimalItems = [];
        }

        if (!tl.StudyDayNotes) {
          tl.StudyDayNotes = [];
        }
      }

      if (nextState.timelines && nextState.timelines.length > 0) {
        nextState.selectedTimeline = nextState.timelines[0];
      } else {
        nextState.selectedTimeline = null;
      }

      nextState.lastRowId = getNextRowId(-1, nextState.timelines);
      break;
    case TIMELINE_REVISION:
      // action.payload is source timeline revision
      const revision = cloneTimeline(
        action.payload,
        action.payload.RevisionNum + 1,
      );
      nextState.timelines = cloneArray(nextState.timelines);
      nextState.timelines.push(revision);
      nextState.selectedTimeline = revision;
      break;
    case TIMELINE_SAVE_SUCCESS:
      // action.payload is returned from API call
      if (!action.payload.TimelineItems) {
        action.payload.TimelineItems = [];
      }

      if (!action.payload.TimelineProjectItems) {
        action.payload.TimelineProjectItems = [];
      }

      if (!action.payload.TimelineAnimalItems) {
        action.payload.TimelineAnimalItems = [];
      }

      if (!action.payload.StudyDayNotes) {
        action.payload.StudyDayNotes = [];
      }

      // Set rowid for UI display
      action.payload.RowId = action.payload.TimelineId;
      action.payload.IsDirty = false;
      action.payload.savedDraft = action.payload.QcStateLabel === "In Progress";

      // Update list of timelines
      let timelines = nextState.timelines.map((timeline) => {
        // Updating existing timeline
        if (
          timeline.TimelineId &&
          timeline.TimelineId === action.payload.TimelineId &&
          timeline.RevisionNum === action.payload.RevisionNum
        ) {
          return action.payload;
        }
        // Saving new timeline
        if (
          !timeline.ObjectId &&
          timeline.RowId === nextState.selectedTimeline.RowId
        ) {
          return action.payload;
        }
        return timeline;
      });

      nextState.timelines = timelines;
      nextState.selectedTimeline = action.payload;
      nextState.selectedTimeline.forceRowRecalc = true;

      // Set Study Day 0 if necessary
      setStudyDay0(nextState.selectedTimeline);

      break;
    case TIMELINE_SELECTED:
      nextState.selectedTimeline = action.payload;

      // Set Study Day 0 if necessary
      setStudyDay0(nextState.selectedTimeline);

      break;
    case UPDATE_SELECTED_TIMELINE:
      nextState.selectedTimeline = {
        ...nextState.selectedTimeline,
        ...action.payload.timeline,
      };
      if (typeof action.payload.dirty !== "undefined") {
        nextState.selectedTimeline.IsDirty =
          action.payload.dirty || nextState.selectedTimeline.IsDirty;
      } else {
        nextState.selectedTimeline.IsDirty = true;
      }
      break;
    case UPDATE_STUDY_DAY_NOTE:
      // action payload is study note
      const { note } = action.payload;

      let updatedNote = false;
      nextState.selectedTimeline.StudyDayNotes =
        nextState.selectedTimeline.StudyDayNotes.map((savedNote) => {
          if (note.RowIdx === savedNote.RowIdx) {
            updatedNote = true;
            if (note.StudyDayNote !== savedNote.StudyDayNote) {
              savedNote = { ...note };
              // savedNote.StudyDayNote = note.StudyDayNote;
              savedNote.IsDirty = true;
            }
          }

          return savedNote;
        });

      if (!updatedNote) {
        nextState.selectedTimeline.StudyDayNotes.push({
          IsDirty: true,
          RowIdx: note.RowIdx,
          StudyDay: note.StudyDay,
          StudyDayNote: note.StudyDayNote,
        });
      }

      break;
    case UPDATE_TIMELINE_ANIMAL_ITEM:
      // action payload is the animal item
      if (
        nextState.selectedTimeline &&
        nextState.selectedTimeline.TimelineAnimalItems
      ) {
        nextState.selectedTimeline.TimelineAnimalItems =
          nextState.selectedTimeline.TimelineAnimalItems.map((item) => {
            if (item.AnimalId === action.payload.AnimalId) {
              return { ...action.payload };
            }
            return item;
          });
      }

      nextState.selectedTimeline.IsDirty = true;
      break;
    case UPDATE_TIMELINE_ITEM:
      // action payload is timeline item
      nextState.selectedTimeline.TimelineItems =
        nextState.selectedTimeline.TimelineItems.map((item) => {
          if (
            (action.payload.item.ObjectId &&
              action.payload.item.ObjectId === item.ObjectId) ||
            (!action.payload.item.ObjectId &&
              action.payload.item.RowIdx === item.RowIdx &&
              action.payload.item.ProjectItemId === item.ProjectItemId)
          ) {
            return { ...item, ...action.payload.item };
          } else return item;
        });
      if (typeof action.payload.dirty !== "undefined") {
        nextState.selectedTimeline.IsDirty =
          action.payload.dirty || nextState.selectedTimeline.IsDirty;
      } else {
        nextState.selectedTimeline.IsDirty = true;
      }

      break;
    case UPDATE_TIMELINE_PROJECT_ITEM:
      // action.payload is project item
      nextState.selectedTimeline = { ...nextState.selectedTimeline };
      nextState.selectedTimeline.TimelineProjectItems =
        nextState.selectedTimeline.TimelineProjectItems.map((projItem) => {
          if (projItem.ProjectItemId === action.payload.ProjectItemId) {
            projItem = { ...projItem, ...action.payload };
          }

          return projItem;
        });

      nextState.selectedTimeline.IsDirty = true;

      break;
    case UPDATE_TIMELINE_ROW:
      // action payload is timeline item
      const { RowIdx, ScheduleDate, StudyDay, StudyDayNote } = action.payload;

      const safeStudyDay = Number.isInteger(Number(StudyDay))
        ? Number(StudyDay)
        : undefined;

      nextState.selectedTimeline.TimelineItems =
        nextState.selectedTimeline.TimelineItems.map((item) => {
          if (RowIdx === item.RowIdx) {
            item = { ...item };
            item.StudyDay = safeStudyDay;
            item.ScheduleDate = ScheduleDate;
            item.IsDirty = true;
          }
          return item;
        });

      // Update study day note
      let updated = false;
      if (StudyDayNote) {
        nextState.selectedTimeline.StudyDayNotes =
          nextState.selectedTimeline.StudyDayNotes.map((note) => {
            if (RowIdx === note.RowIdx) {
              updated = true;
              if (
                StudyDayNote !== note.StudyDayNote ||
                safeStudyDay !== note.StudyDay
              ) {
                note.StudyDayNote = StudyDayNote;
                note.StudyDay = safeStudyDay;
                note.IsDirty = true;
              }
            }

            return note;
          });

        if (!updated) {
          nextState.selectedTimeline.StudyDayNotes.push({
            IsDirty: true,
            RowIdx: RowIdx,
            StudyDay: safeStudyDay,
            StudyDayNote: StudyDayNote,
          });
        }
      }

      nextState.selectedTimeline.IsDirty = true;

      break;
  }
  if (verboseOutput) {
    console.log("timelineReducer() -> " + action.type + "\nnext state:");
    console.log(nextState);
  }
  return nextState;
};
