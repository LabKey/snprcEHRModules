export interface Project {
    projectId?: number;
    description?: string;
    Iacuc?: string;
    CostAccount?: string;
    referenceId?: string;
    Veterinarian1?: string;
    Veterinarian2?: string;
    VsNumber?: string;
    startDate?: string;
    endDate?: string;
    FeeScheduler?: string;
    revisionNum?: number;
    ProjectObjectId?: string;
    ProjectItems?: any[];
    objectId?: string;
}

export interface Timeline {
    RowId?: number;
    TimelineId?: number;
    RevisionNum?: number;
    Description?: string;
    QcStateLabel?: string;
    IsDirty?: boolean;
    ObjectId?: string;
    TimelineItems?: any[];
    TimelineProjectItems?: any[];
    TimelineAnimalItems?: any[];
    StudyDayNotes?: any[];
    StudyDay0?: string;
    RC?: string;
    LeadTech?: string;
    AnimalAccount?: string;
    Created?: string;
    CreatedByName?: string;
    Modified?: string;
    ModifiedByName?: string;
    StartDate?: string;
    EndDate?: string;
    Notes?: string;
    SchedulerNotes?: string;
    IsInUse?: boolean;
    savedDraft?: boolean;
}

export interface Animal {
    Id?: string;
    AssignmentStatus?: string;
    Gender?: string;
    Weight?: number;
    Age?: string;
    AnimalId?: string;
    IsDeleted?: boolean;
    IsDirty?: boolean;
    assigned?: boolean;
    EndDate?: string;
}
